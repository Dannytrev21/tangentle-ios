#!/usr/bin/env python3
"""
Tangentle Plan CLI - Intelligent planning system orchestrator.

This CLI tool provides a unified interface for plan management,
integrating the classifier, selector, and assessor components.
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
from utils import (
    find_plan,
    load_plan_progress,
    list_all_plans,
    format_box,
    format_progress_bar,
    format_risk_level,
    format_status,
    get_current_step,
    get_thinking_keyword,
    get_thinking_keyword_description,
    PLANS_DIR
)


class PlanOrchestrator:
    """
    Orchestrates plan management with intelligent technique selection.

    Integrates the classifier, selector, and assessor to provide
    a unified interface for plan operations.
    """

    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """
        Initialize the orchestrator with all components.

        Args:
            config_path: Path to technique configuration file
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

    def get_risk_for_type(self, problem_type: str) -> str:
        """
        Get the default risk level for a problem type.

        Args:
            problem_type: The problem type

        Returns:
            Risk level string (low, medium, high, critical)
        """
        return self.selector.get_risk_for_problem_type(problem_type)

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

    # Get risk level and thinking keyword
    risk_level = orchestrator.get_risk_for_type(args.problem_type)
    thinking_keyword = orchestrator.selector.get_thinking_keyword(risk_level)

    content = [
        f"Problem Type: {args.problem_type}",
        f"Risk Level: {risk_level}",
        f"Thinking Keyword: {thinking_keyword}",
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


def cmd_thinking(args, orchestrator: PlanOrchestrator) -> int:
    """Handle thinking subcommand."""
    risk_level = args.risk_level.lower()
    keyword = get_thinking_keyword(risk_level)
    description = get_thinking_keyword_description(keyword)

    content = [
        f"Risk Level: {risk_level}",
        f"Thinking Keyword: {keyword}",
        f"Description: {description}",
    ]

    print(format_box("THINKING KEYWORD", content))
    return 0


def cmd_help(args, orchestrator: PlanOrchestrator) -> int:
    """Handle help subcommand."""
    help_text = """
Tangentle Plan CLI - Intelligent Planning System

USAGE:
  tangentle-plan <command> [options]

COMMANDS:
  classify <description>   Classify a problem description
  techniques <type>        Show techniques for a problem type
  thinking <risk_level>    Get thinking keyword for a risk level
  risk <type>              Assess risk for a step
  status <plan_id>         Show plan status
  list                     List all plans

EXAMPLES:
  tangentle-plan classify "Fix the crash when saving"
  tangentle-plan techniques debug
  tangentle-plan risk migration --migration --persistence
  tangentle-plan status 004
  tangentle-plan list

OPTIONS:
  --help, -h              Show this help message

For more information, see: .claude/plans/README.md
"""
    print(help_text)
    return 0


def main() -> int:
    """Main entry point for the CLI."""
    # Change to project root if we're in scripts directory
    if Path.cwd().name == "scripts" and Path(".claude").exists() is False:
        os.chdir(Path(__file__).parent.parent.parent)

    parser = argparse.ArgumentParser(
        description="Tangentle Plan - Intelligent planning system",
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

    # thinking
    p = subparsers.add_parser("thinking", help="Get thinking keyword for a risk level")
    p.add_argument("risk_level", help="Risk level (low, medium, high, critical)")

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

    # Placeholder commands (not yet implemented)
    p = subparsers.add_parser("create", help="Create a new plan (not yet implemented)")
    p.add_argument("description", help="Feature description")
    p.add_argument("--type", help="Explicit problem type")

    p = subparsers.add_parser("prompts", help="Generate prompts (not yet implemented)")
    p.add_argument("plan_id", help="Plan identifier")

    p = subparsers.add_parser("next", help="Execute next step (not yet implemented)")
    p.add_argument("plan_id", help="Plan identifier")

    p = subparsers.add_parser("verify", help="Verify current step (not yet implemented)")
    p.add_argument("plan_id", help="Plan identifier")

    p = subparsers.add_parser("rollback", help="Rollback current step (not yet implemented)")
    p.add_argument("plan_id", help="Plan identifier")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    # Initialize orchestrator
    try:
        orchestrator = PlanOrchestrator()
    except Exception as e:
        print(f"Error initializing orchestrator: {e}")
        return 1

    # Dispatch to handlers
    handlers = {
        "classify": cmd_classify,
        "techniques": cmd_techniques,
        "thinking": cmd_thinking,
        "risk": cmd_risk,
        "status": cmd_status,
        "list": cmd_list,
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
