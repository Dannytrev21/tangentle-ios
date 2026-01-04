#!/usr/bin/env python3
"""
Windsurf Plan CLI - Intelligent planning system orchestrator.

This CLI tool provides a unified interface for plan management,
integrating the classifier, selector, and assessor components.

Uses standard library only - no pip dependencies.
"""

import argparse
import sys
import os
from pathlib import Path
from typing import Optional

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from problem_classifier import ProblemClassifier, ClassificationResult
from technique_selector import TechniqueSelector, Phase, TechniqueSelection
from risk_assessor import RiskAssessor, RiskLevel, StepInfo, RiskAssessment
from memory_bank import MemoryBank, MemoryBankEntry, create_entry
from self_correction import SelfCorrection, get_retry_config
from file_tracker import FileTracker, get_staging_commands_for_step, load_operations_from_progress
from utils import (
    find_plan,
    load_plan_progress,
    list_all_plans,
    format_box,
    format_progress_bar,
    format_risk_level,
    format_status,
    get_current_step,
    PLANS_DIR
)


class PlanOrchestrator:
    """
    Orchestrates plan management with intelligent technique selection.

    Integrates the classifier, selector, and assessor to provide
    a unified interface for plan operations.
    """

    def __init__(self, config_path: Optional[str] = None):
        """
        Initialize the orchestrator with all components.

        Args:
            config_path: Optional path to technique configuration file
        """
        self.classifier = ProblemClassifier(config_path)
        self.selector = TechniqueSelector(config_path)
        self.assessor = RiskAssessor(config_path)

    def classify(self, description: str) -> dict:
        """
        Classify a problem description.

        Args:
            description: The problem description to classify

        Returns:
            Dictionary with classification results
        """
        result = self.classifier.classify(description)
        return {
            "type": result.primary_type,
            "category": result.primary_category,
            "confidence": result.confidence,
            "alternatives": result.alternatives[:3],
            "reasoning": result.reasoning,
            "keywords_matched": result.keywords_matched,
        }

    def get_techniques(self, problem_type: str) -> dict:
        """
        Get recommended techniques for all phases.

        Args:
            problem_type: The problem type

        Returns:
            Dictionary with techniques for each phase
        """
        return {
            "planning": self.selector.select_techniques(
                problem_type, Phase.PLANNING
            ),
            "implementation": self.selector.select_techniques(
                problem_type, Phase.IMPLEMENTATION
            ),
            "verification": self.selector.select_techniques(
                problem_type, Phase.VERIFICATION
            ),
        }

    def assess_risk(self, step_info: dict) -> RiskAssessment:
        """
        Assess risk for a step.

        Args:
            step_info: Dictionary with step information

        Returns:
            RiskAssessment result
        """
        # Convert dict to StepInfo, handling missing keys
        step = StepInfo(
            problem_type=step_info.get("problem_type", "unknown"),
            files_to_create=step_info.get("files_to_create", []),
            files_to_modify=step_info.get("files_to_modify", []),
            dependencies=step_info.get("dependencies", []),
            has_data_migration=step_info.get("has_data_migration", False),
            has_external_api=step_info.get("has_external_api", False),
            affects_persistence=step_info.get("affects_persistence", False),
            is_breaking_change=step_info.get("is_breaking_change", False),
            complexity_estimate=step_info.get("complexity_estimate", "medium"),
        )
        return self.assessor.assess_risk(step)

    def get_plan_status(self, plan_id: str) -> Optional[dict]:
        """
        Get status information for a plan.

        Args:
            plan_id: Plan identifier

        Returns:
            Dictionary with plan status or None if not found
        """
        plan_dir = find_plan(plan_id)
        if not plan_dir:
            return None

        progress = load_plan_progress(plan_dir)
        if not progress:
            return None

        current_step = get_current_step(progress)
        total = progress.get("totalSteps", 0)
        completed = sum(
            1 for s in progress.get("steps", [])
            if s.get("status") == "completed"
        )

        return {
            "plan_id": progress.get("planId"),
            "name": progress.get("name"),
            "title": progress.get("title"),
            "status": progress.get("status"),
            "current_step": progress.get("currentStep"),
            "total_steps": total,
            "completed_steps": completed,
            "progress_pct": (completed / total * 100) if total > 0 else 0,
            "current_step_info": current_step,
            "path": str(plan_dir),
        }


def cmd_classify(args, orchestrator: PlanOrchestrator) -> int:
    """Handle classify subcommand."""
    result = orchestrator.classify(args.description)

    content = [
        f"Type: {result['type']} (Category: {result['category']})",
        f"Confidence: {result['confidence']:.0%}",
        "",
    ]

    if result['keywords_matched']:
        content.append(f"Keywords: {', '.join(result['keywords_matched'][:5])}")
        content.append("")

    content.append("Suggested Techniques:")
    techniques = orchestrator.get_techniques(result['type'])
    content.append(f"  Planning:       {techniques['planning'].primary}")
    content.append(f"  Implementation: {techniques['implementation'].primary}")
    content.append(f"  Verification:   {techniques['verification'].primary}")

    if result['alternatives']:
        content.append("")
        content.append("Alternatives:")
        for alt, conf in result['alternatives']:
            content.append(f"  - {alt} ({conf:.0%})")

    print(format_box("PROBLEM CLASSIFICATION", content))
    return 0


def cmd_status(args, orchestrator: PlanOrchestrator) -> int:
    """Handle status subcommand."""
    status = orchestrator.get_plan_status(args.plan_id)
    if not status:
        print(f"Error: Plan '{args.plan_id}' not found")
        return 1

    content = [
        f"Title: {status['title']}",
        f"Status: {format_status(status['status'])}",
        f"Progress: {status['completed_steps']}/{status['total_steps']} steps ({status['progress_pct']:.0f}%)",
        f"",
        format_progress_bar(status['completed_steps'], status['total_steps']),
        "",
    ]

    step = status.get('current_step_info')
    if step:
        content.append(f"Current Step: {step.get('title', 'Unknown')}")
        content.append(f"  Type: {step.get('problemType', 'unknown')}")
        content.append(f"  Risk: {format_risk_level(step.get('riskLevel', 'unknown'))}")

        techs = step.get("techniques", {})
        if techs:
            content.append(f"  Techniques:")
            content.append(f"    Planning: {techs.get('planning', 'N/A')}")
            impl = techs.get('implementation', [])
            impl_str = ", ".join(impl) if isinstance(impl, list) else impl
            content.append(f"    Implementation: {impl_str}")
            content.append(f"    Verification: {techs.get('verification', 'N/A')}")

    print(format_box(f"PLAN {status['plan_id']}: {status['name']}", content))
    return 0


def cmd_list(args, orchestrator: PlanOrchestrator) -> int:
    """Handle list subcommand."""
    plans = list_all_plans()

    if not plans:
        print("No plans found")
        return 0

    print()
    print("=" * 70)
    print("  PLANS")
    print("=" * 70)

    for plan in plans:
        progress_bar = format_progress_bar(
            plan['completed_steps'],
            plan['total_steps'],
            width=20
        )
        print(f"  {plan['id']}: {plan['title']}")
        print(f"      Status: {format_status(plan['status'])}")
        print(f"      Progress: {plan['completed_steps']}/{plan['total_steps']} {progress_bar}")
        print()

    print("=" * 70)
    return 0


def cmd_techniques(args, orchestrator: PlanOrchestrator) -> int:
    """Handle techniques subcommand."""
    techniques = orchestrator.get_techniques(args.problem_type)

    content = [
        f"Problem Type: {args.problem_type}",
        "",
        "Planning Phase:",
        f"  Primary: {techniques['planning'].primary}",
        f"  Secondary: {', '.join(techniques['planning'].secondary) or 'None'}",
        f"  Cost: {techniques['planning'].estimated_cost}",
        "",
        "Implementation Phase:",
        f"  Primary: {techniques['implementation'].primary}",
        f"  Secondary: {', '.join(techniques['implementation'].secondary) or 'None'}",
        f"  Cost: {techniques['implementation'].estimated_cost}",
        "",
        "Verification Phase:",
        f"  Primary: {techniques['verification'].primary}",
        f"  Secondary: {', '.join(techniques['verification'].secondary) or 'None'}",
        f"  Cost: {techniques['verification'].estimated_cost}",
        "",
        f"Retry Budget: {techniques['planning'].retry_budget} attempts",
    ]

    print(format_box("TECHNIQUE SELECTION", content))
    return 0


def cmd_risk(args, orchestrator: PlanOrchestrator) -> int:
    """Handle risk subcommand."""
    # Build step info from args
    step_info = {
        "problem_type": args.type,
        "has_data_migration": args.migration,
        "has_external_api": args.api,
        "is_breaking_change": args.breaking,
        "affects_persistence": args.persistence,
        "complexity_estimate": args.complexity,
    }

    if args.files:
        step_info["files_to_modify"] = args.files.split(",")

    result = orchestrator.assess_risk(step_info)

    content = [
        f"Problem Type: {args.type}",
        f"Risk Level: {format_risk_level(result.level.value)}",
        f"Risk Score: {result.score:.2f}",
        "",
        f"Retry Budget: {result.retry_config.max_total} attempts",
        f"Escalation Threshold: {result.retry_config.escalation_threshold}",
        "",
        "Explanation:",
        f"  {result.explanation}",
    ]

    if result.mitigations:
        content.append("")
        content.append("Suggested Mitigations:")
        for m in result.mitigations[:5]:
            content.append(f"  - {m}")

    # Show active factors
    active_factors = [f for f in result.factors if f.present]
    if active_factors:
        content.append("")
        content.append("Active Risk Factors:")
        for f in active_factors:
            sign = "+" if f.weight > 0 else ""
            content.append(f"  {sign}{f.weight:.2f} {f.name}")

    print(format_box("RISK ASSESSMENT", content))
    return 0


def cmd_memory(args, orchestrator: PlanOrchestrator) -> int:
    """Handle memory subcommand for memory bank operations."""
    plan_dir = find_plan(args.plan)
    if not plan_dir:
        print(f"Error: Plan '{args.plan}' not found")
        return 1

    bank = MemoryBank(str(plan_dir))

    if args.action == "list":
        entries = bank.get_entries(args.limit)
        if not entries:
            print("No entries in memory bank")
            return 0

        content = [f"Plan: {args.plan}", f"Entries: {len(bank)}", ""]
        for i, e in enumerate(entries, 1):
            content.append(f"{i}. [{e.failureType}] Step {e.stepId}")
            content.append(f"   Context: {e.context[:50]}...")
            if e.lesson:
                content.append(f"   Lesson: {e.lesson}")
            content.append("")

        print(format_box("MEMORY BANK", content))

    elif args.action == "add":
        entry = create_entry(
            step_id=args.step,
            failure_type=args.type,
            context=args.context,
            technique=args.technique,
            lesson=args.lesson or ""
        )
        bank.add_entry(entry)
        print(f"Added entry for step {args.step}")

    elif args.action == "clear":
        bank.clear()
        print(f"Memory bank cleared for plan {args.plan}")

    elif args.action == "context":
        context = bank.to_prompt_context(args.limit)
        print(context)

    return 0


def cmd_retry(args, orchestrator: PlanOrchestrator) -> int:
    """Handle retry subcommand for self-correction evaluation."""
    plan_dir = find_plan(args.plan)
    if not plan_dir:
        print(f"Error: Plan '{args.plan}' not found")
        return 1

    bank = MemoryBank(str(plan_dir))
    engine = SelfCorrection(bank, risk_level=args.risk)

    result = engine.evaluate_failure(
        step_id=args.step,
        failure_type=args.failure_type,
        failure_message=args.message,
        current_technique=args.technique,
        attempts={"same": args.same, "alt": args.alt}
    )

    content = [
        f"Step: {args.step}",
        f"Risk Level: {args.risk.upper()}",
        f"Current Technique: {args.technique}",
        f"Attempts: {args.same} same, {args.alt} alternative",
        "",
        f"Recommended Action: {result.action.upper()}",
        f"Technique: {result.technique}",
        f"Remaining Budget: {result.remaining_budget}",
        "",
        "Rationale:",
        f"  {result.rationale}",
    ]

    if result.guidance:
        content.append("")
        content.append("Guidance from Memory Bank:")
        for g in result.guidance[:5]:
            content.append(f"  - {g}")

    print(format_box("RETRY EVALUATION", content))
    return 0


def cmd_budget(args, orchestrator: PlanOrchestrator) -> int:
    """Handle budget subcommand to show retry budgets."""
    config = get_retry_config(args.risk)

    content = [
        f"Risk Level: {args.risk.upper()}",
        "",
        f"Same Technique Retries: {config['max_same']}",
        f"Alternative Technique Retries: {config['max_alt']}",
        f"Total Budget: {config['max_total']}",
        f"Escalate After: {config['escalate_after']} attempts",
    ]

    print(format_box("RETRY BUDGET", content))
    return 0


def cmd_stage(args, orchestrator: PlanOrchestrator) -> int:
    """Handle stage subcommand to get staging commands for a step."""
    plan_dir = find_plan(args.plan)
    if not plan_dir:
        print(f"Error: Plan '{args.plan}' not found")
        return 1

    operations = load_operations_from_progress(str(plan_dir), args.step)

    # Check if there are any operations
    total_ops = (
        len(operations.get('created', [])) +
        len(operations.get('modified', [])) +
        len(operations.get('deleted', [])) +
        len(operations.get('renamed', []))
    )

    if total_ops == 0:
        print(f"No file operations recorded for step {args.step}")
        return 0

    tracker = FileTracker()
    commands = tracker.get_staging_commands(operations)

    content = [
        f"Plan: {args.plan}",
        f"Step: {args.step}",
        "",
        "File Operations:",
        f"  Created:  {len(operations.get('created', []))}",
        f"  Modified: {len(operations.get('modified', []))}",
        f"  Deleted:  {len(operations.get('deleted', []))}",
        f"  Renamed:  {len(operations.get('renamed', []))}",
        "",
        "Staging Commands:",
    ]

    for cmd in commands:
        content.append(f"  $ {cmd}")

    if not commands:
        content.append("  (no commands - all files excluded)")

    print(format_box("STAGING COMMANDS", content))

    # Also output just the commands for piping
    if args.raw:
        for cmd in commands:
            print(cmd)

    return 0


def cmd_help(args, orchestrator: PlanOrchestrator) -> int:
    """Handle help subcommand."""
    help_text = """
Windsurf Plan CLI - Intelligent Planning System

USAGE:
  windsurf_plan.py <command> [options]

COMMANDS:
  classify <description>   Classify a problem description
  techniques <type>        Show techniques for a problem type
  risk <type>              Assess risk for a step
  status <plan_id>         Show plan status
  list                     List all plans
  memory <action>          Memory bank operations
  retry                    Evaluate retry strategy
  budget <risk_level>      Show retry budget for risk level
  stage                    Get staging commands for a step

MEMORY BANK COMMANDS:
  memory list --plan <id>
  memory add --plan <id> --step <n> --type <type> --context <ctx>
  memory clear --plan <id>
  memory context --plan <id>

RETRY COMMAND:
  retry --plan <id> --step <n> --technique <tech> --message <msg> \\
        --same <n> --alt <n> --risk <level>

STAGE COMMAND:
  stage --plan <id> --step <n>
  stage --plan <id> --step <n> --raw

EXAMPLES:
  windsurf_plan.py classify "Fix the crash when saving"
  windsurf_plan.py techniques debug
  windsurf_plan.py risk migration --migration --persistence
  windsurf_plan.py status 004
  windsurf_plan.py memory list --plan 005
  windsurf_plan.py retry --plan 005 --step 3 --technique tdd \\
                         --message "test failed" --same 2 --alt 0
  windsurf_plan.py budget high
  windsurf_plan.py stage --plan 005 --step 15

OPTIONS:
  --help, -h              Show this help message

For more information, see: .windsurf/README.md
"""
    print(help_text)
    return 0


def main() -> int:
    """Main entry point for the CLI."""
    # Change to project root if we're in scripts directory
    if Path.cwd().name == "scripts" and not Path(".windsurf").exists():
        os.chdir(Path(__file__).parent.parent.parent)

    parser = argparse.ArgumentParser(
        description="Windsurf Plan - Intelligent planning system",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s classify "Fix the crash when saving"
  %(prog)s techniques debug
  %(prog)s risk migration --migration --persistence
  %(prog)s status 004
  %(prog)s list
"""
    )
    subparsers = parser.add_subparsers(dest="command")

    # classify
    p = subparsers.add_parser("classify", help="Classify a problem description")
    p.add_argument("description", help="Problem description to classify")

    # techniques
    p = subparsers.add_parser("techniques", help="Show techniques for a problem type")
    p.add_argument("problem_type", help="Problem type (e.g., debug, ui, migration)")

    # risk
    p = subparsers.add_parser("risk", help="Assess risk for a step")
    p.add_argument("type", help="Problem type")
    p.add_argument("--migration", action="store_true", help="Involves data migration")
    p.add_argument("--api", action="store_true", help="Uses external API")
    p.add_argument("--breaking", action="store_true", help="Is a breaking change")
    p.add_argument("--persistence", action="store_true", help="Affects persistence layer")
    p.add_argument("--complexity", default="medium", choices=["low", "medium", "high"],
                   help="Complexity estimate")
    p.add_argument("--files", help="Comma-separated list of files to modify")

    # status
    p = subparsers.add_parser("status", help="Show plan status")
    p.add_argument("plan_id", help="Plan identifier (e.g., 004)")

    # list
    subparsers.add_parser("list", help="List all plans")

    # memory
    p = subparsers.add_parser("memory", help="Memory bank operations")
    p.add_argument("action", choices=["list", "add", "clear", "context"],
                   help="Action to perform")
    p.add_argument("--plan", required=True, help="Plan identifier")
    p.add_argument("--step", type=int, default=0, help="Step ID (for add)")
    p.add_argument("--type", dest="type", default="unknown", help="Failure type (for add)")
    p.add_argument("--context", default="", help="Context description (for add)")
    p.add_argument("--technique", default="manual", help="Technique used (for add)")
    p.add_argument("--lesson", default="", help="Lesson learned (for add)")
    p.add_argument("--limit", type=int, default=10, help="Max entries to show")

    # retry
    p = subparsers.add_parser("retry", help="Evaluate retry strategy")
    p.add_argument("--plan", required=True, help="Plan identifier")
    p.add_argument("--step", type=int, required=True, help="Step ID")
    p.add_argument("--technique", required=True, help="Current technique")
    p.add_argument("--message", default="", help="Failure message")
    p.add_argument("--failure-type", dest="failure_type", default="unknown",
                   help="Type of failure")
    p.add_argument("--same", type=int, default=0, help="Same-technique attempts")
    p.add_argument("--alt", type=int, default=0, help="Alternative-technique attempts")
    p.add_argument("--risk", default="medium",
                   choices=["low", "medium", "high", "critical"],
                   help="Risk level")

    # budget
    p = subparsers.add_parser("budget", help="Show retry budget for risk level")
    p.add_argument("risk", choices=["low", "medium", "high", "critical"],
                   help="Risk level")

    # stage
    p = subparsers.add_parser("stage", help="Get staging commands for a step")
    p.add_argument("--plan", required=True, help="Plan identifier")
    p.add_argument("--step", type=int, required=True, help="Step number")
    p.add_argument("--raw", action="store_true", help="Output commands only (for piping)")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    # Initialize orchestrator (no config file required - uses built-in defaults)
    try:
        orchestrator = PlanOrchestrator()
    except Exception as e:
        print(f"Error initializing orchestrator: {e}")
        return 1

    # Dispatch to handlers
    handlers = {
        "classify": cmd_classify,
        "techniques": cmd_techniques,
        "risk": cmd_risk,
        "status": cmd_status,
        "list": cmd_list,
        "memory": cmd_memory,
        "retry": cmd_retry,
        "budget": cmd_budget,
        "stage": cmd_stage,
    }

    handler = handlers.get(args.command)
    if handler:
        try:
            return handler(args, orchestrator)
        except Exception as e:
            print(f"Error: {e}")
            return 1
    else:
        print(f"Command '{args.command}' not yet implemented")
        return 0


if __name__ == "__main__":
    sys.exit(main())
