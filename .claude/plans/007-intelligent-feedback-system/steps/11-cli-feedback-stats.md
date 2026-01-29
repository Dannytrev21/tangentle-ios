# Step 11: CLI Feedback Stats Command

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Clear output requirements
- **Implementation**: self-refine - Iterate on display quality
- **Verification**: self-refine - Refine until clear

## Risk Level
**low** - Read-only display command

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
This step adds a `/feedback` command and CLI subcommand to view effectiveness statistics. Users can see which techniques work best for which problem types, helping them understand how the system learns.

## Goal
Create feedback viewing capabilities:
1. `/feedback` skill for interactive viewing
2. `python3 tangentle_plan.py feedback` for CLI
3. Clear, informative statistics display
4. Insights and recommendations

## Prerequisites
- Step 3 (Effectiveness Tracker) completed
- Step 8 (Plan-Next Integration) completed

## High-Level Steps
1. Create /feedback skill
2. Add feedback subcommand to CLI
3. Design statistics display
4. Add recommendations based on data
5. Test with sample data

## Detailed Requirements

### /feedback Command File

Create `.claude/commands/feedback.md`:

```markdown
# Feedback Statistics Command

View technique effectiveness statistics and planning system insights.

## Input
Options: $ARGUMENTS

## Usage

```bash
/feedback              # Show summary statistics
/feedback detailed     # Show detailed breakdown
/feedback techniques   # Focus on technique effectiveness
/feedback types        # Focus on problem types
/feedback recent       # Show recent activity
```

## Process

### Load Feedback Data

```python
from scripts.feedback_store import FeedbackStore
from scripts.effectiveness_tracker import EffectivenessTracker

store = FeedbackStore()
tracker = EffectivenessTracker(store)

effectiveness_data = store.get_effectiveness_data()
metrics = store.get_metrics()
```

### Display Based on Mode

#### Summary Mode (default)

```
═══════════════════════════════════════════════════════════════
  PLANNING SYSTEM FEEDBACK - SUMMARY
═══════════════════════════════════════════════════════════════

  ## Overview
  - Total Plans: {n}
  - Total Steps: {n}
  - Completion Rate: {%}
  - Average Steps/Plan: {n}

  ## Technique Effectiveness (Top 5)

  | Technique | Success Rate | Samples | Trend |
  |-----------|--------------|---------|-------|
  | TDD | 85% | 42 | ↑ |
  | Self-Refine | 78% | 35 | → |
  | Reflexion | 73% | 28 | ↓ |
  | ToT | 70% | 15 | → |
  | PS-Plus | 68% | 50 | ↑ |

  ## Problem Types (Most Active)

  | Type | Steps | Success Rate |
  |------|-------|--------------|
  | debug | 25 | 72% |
  | ui | 20 | 88% |
  | refactor | 18 | 80% |

  ## Key Insights
  - TDD has highest success rate (85%)
  - 'debug' problems benefit most from Reflexion (+12%)
  - Average 2.3 attempts per step

  Run `/feedback detailed` for full breakdown.
═══════════════════════════════════════════════════════════════
```

#### Detailed Mode

```
═══════════════════════════════════════════════════════════════
  PLANNING SYSTEM FEEDBACK - DETAILED
═══════════════════════════════════════════════════════════════

  ## Technique Effectiveness by Problem Type

  ### debug
  | Technique | Success | Fail | Rate | Avg Attempts |
  |-----------|---------|------|------|--------------|
  | reflexion | 18 | 5 | 78% | 1.8 |
  | tdd | 12 | 8 | 60% | 2.5 |
  | self-refine | 8 | 4 | 67% | 2.1 |

  ### ui
  | Technique | Success | Fail | Rate | Avg Attempts |
  |-----------|---------|------|------|--------------|
  | self-refine | 15 | 2 | 88% | 1.3 |
  | tdd | 8 | 3 | 73% | 1.8 |

  ### service-impl
  | Technique | Success | Fail | Rate | Avg Attempts |
  |-----------|---------|------|------|--------------|
  | tdd | 20 | 3 | 87% | 1.5 |
  | self-refine | 10 | 4 | 71% | 2.0 |

  ## Recommendations

  Based on your data:
  - Use **Reflexion** for `debug` (78% vs config default 65%)
  - Use **Self-Refine** for `ui` (88% vs TDD 73%)
  - Keep **TDD** for `service-impl` (87%, already optimal)

  ## Data Quality
  - Confidence: High (100+ samples)
  - Coverage: 8/12 problem types with data
  - Recency: Last update {date}

═══════════════════════════════════════════════════════════════
```

#### Techniques Mode

```
═══════════════════════════════════════════════════════════════
  TECHNIQUE EFFECTIVENESS ANALYSIS
═══════════════════════════════════════════════════════════════

  ## TDD
  Overall: 85% success rate (42 samples)

  Best for:
  - service-impl: 87%
  - unit-test: 92%
  - algorithm: 80%

  Avoid for:
  - ui: 60% (use Self-Refine instead: 88%)
  - documentation: 50% (use PS-Plus: 75%)

  ────────────────────────────────────────────────────────────

  ## Reflexion
  Overall: 73% success rate (28 samples)

  Best for:
  - debug: 78%
  - algorithm: 75%

  Avoid for:
  - infrastructure: 55% (use PS-Plus: 70%)

  ...

═══════════════════════════════════════════════════════════════
```

#### Recent Mode

```
═══════════════════════════════════════════════════════════════
  RECENT FEEDBACK ACTIVITY
═══════════════════════════════════════════════════════════════

  ## Last 10 Step Completions

  | Date | Plan | Step | Type | Technique | Result |
  |------|------|------|------|-----------|--------|
  | Jan 25 | 007 | 3 | service | tdd | ✓ |
  | Jan 25 | 007 | 2 | infra | ps-plus | ✓ |
  | Jan 24 | 006 | 12 | test | tdd | ✓ |
  | Jan 24 | 006 | 11 | doc | self-refine | ✓ |
  | ... | ... | ... | ... | ... | ... |

  ## Last 5 Classification Corrections

  | Date | Original | Corrected | Description |
  |------|----------|-----------|-------------|
  | Jan 25 | ui | service-impl | "Add API for..." |
  | Jan 23 | debug | refactor | "Clean up..." |

═══════════════════════════════════════════════════════════════
```

### Handle Empty Data

If no feedback data exists:

```
═══════════════════════════════════════════════════════════════
  PLANNING SYSTEM FEEDBACK
═══════════════════════════════════════════════════════════════

  No feedback data collected yet.

  To start collecting data:
  1. Run /plan-feature to create a plan
  2. Run /plan-prompts to generate prompts
  3. Run /plan-next to execute steps

  After completing steps, feedback data will appear here.

  Minimum samples needed for recommendations: 10

═══════════════════════════════════════════════════════════════
```
```

### CLI Subcommand

Add to `.claude/scripts/tangentle_plan.py`:

```python
def cmd_feedback(args):
    """Display feedback statistics."""
    store = FeedbackStore()
    tracker = EffectivenessTracker(store)

    mode = args.mode if hasattr(args, 'mode') else 'summary'

    if mode == 'summary':
        display_summary(store, tracker)
    elif mode == 'detailed':
        display_detailed(store, tracker)
    elif mode == 'techniques':
        display_techniques(store, tracker)
    elif mode == 'types':
        display_types(store, tracker)
    elif mode == 'recent':
        display_recent(store)
    elif mode == 'json':
        # Raw JSON output for scripting
        print(json.dumps(store.get_effectiveness_data(), indent=2))
    else:
        print(f"Unknown mode: {mode}")
        print("Available: summary, detailed, techniques, types, recent, json")

# Add to argparse
feedback_parser = subparsers.add_parser('feedback', help='View feedback statistics')
feedback_parser.add_argument('mode', nargs='?', default='summary',
    choices=['summary', 'detailed', 'techniques', 'types', 'recent', 'json'])
feedback_parser.set_defaults(func=cmd_feedback)
```

## Files to Create
- `.claude/commands/feedback.md`: Feedback viewing skill

## Files to Modify
- `.claude/scripts/tangentle_plan.py`: Add feedback subcommand

## Patterns to Follow
Reference: `.claude/commands/plan-status.md` for display patterns

## Acceptance Criteria
- [ ] /feedback skill works interactively
- [ ] CLI subcommand works
- [ ] All display modes render correctly
- [ ] Empty data handled gracefully
- [ ] Recommendations are sensible
- [ ] JSON output mode works for scripting

## Testing Requirements

### Manual Tests
- [ ] Test all display modes
- [ ] Test with no data
- [ ] Test with sample data
- [ ] Test CLI subcommand
- [ ] Verify recommendations make sense

### What to Test
- Display formatting
- Calculation accuracy
- Edge cases (no data, partial data)
- CLI integration

## Verification Commands
```bash
# Test CLI subcommand
cd .claude && python3 scripts/tangentle_plan.py feedback

# Test JSON output
cd .claude && python3 scripts/tangentle_plan.py feedback json | head -20

# Verify command file
cat .claude/commands/feedback.md | head -30
```

## Documentation Updates
- [ ] Add /feedback to CLAUDE.md command list
- [ ] Document feedback modes

## Error Recovery
If verification fails:
1. Check store data loading
2. Verify calculation logic
3. Test display with mock data

## Do NOT
- Modify feedback data (read-only)
- Make complex recommendations without data
- Skip empty data handling
