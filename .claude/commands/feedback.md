# Feedback Statistics Command

View technique effectiveness statistics and planning system insights.

## Input
Mode: $ARGUMENTS

## Usage

```bash
/feedback              # Show summary statistics
/feedback detailed     # Show detailed breakdown by problem type
/feedback techniques   # Focus on technique effectiveness
/feedback types        # Focus on problem types
/feedback recent       # Show recent activity
/feedback json         # Raw JSON output for scripting
```

## Available Modes

| Mode | Description |
|------|-------------|
| `summary` | Overview, top techniques, key insights (default) |
| `detailed` | Full breakdown by problem type and technique |
| `techniques` | Focus on technique effectiveness rankings |
| `types` | Focus on problem type statistics |
| `recent` | Last 10 completions, last 5 corrections |
| `json` | Raw JSON output for scripting |

## Process

### Step 1: Load Feedback Data

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from effectiveness_tracker import EffectivenessTracker

store = FeedbackStore()
tracker = EffectivenessTracker(store)

effectiveness_data = store.get_effectiveness_data()
metrics = store.get_metrics()
```

### Step 2: Display Based on Mode

Parse the mode from $ARGUMENTS (default: "summary").

#### Summary Mode (Default)

```
===============================================================
  PLANNING SYSTEM FEEDBACK - SUMMARY
===============================================================

  ## Overview
  - Total Plans: {metrics.totalPlans}
  - Total Steps: {metrics.totalSteps}
  - Completed Steps: {metrics.completedSteps}
  - Completion Rate: {completedSteps / totalSteps}%

  ## Technique Effectiveness (Top 5)

  | Technique | Success Rate | Samples | Trend |
  |-----------|--------------|---------|-------|
  | {technique} | {rate}% | {samples} | {trend} |

  ## Problem Types (Most Active)

  | Type | Total Uses | Success Rate |
  |------|------------|--------------|
  | {type} | {uses} | {rate}% |

  ## Key Insights
  - {top technique} has highest success rate ({rate}%)
  - Average attempts per step: {avg}
  - {samples_info based on MIN_SAMPLES threshold}

  Run `/feedback detailed` for full breakdown.
===============================================================
```

#### Detailed Mode

```
===============================================================
  PLANNING SYSTEM FEEDBACK - DETAILED
===============================================================

  ## By Problem Type

  ### {problem_type}

  | Technique | Success | Failure | Rate | Avg Attempts |
  |-----------|---------|---------|------|--------------|
  | {tech} | {succ} | {fail} | {rate}% | {avg} |

  (repeat for each problem type)

===============================================================
```

#### Techniques Mode

```
===============================================================
  TECHNIQUE EFFECTIVENESS RANKINGS
===============================================================

  | Rank | Technique | Success Rate | Total Samples | Status |
  |------|-----------|--------------|---------------|--------|
  | 1 | {tech} | {rate}% | {samples} | {reliable/limited} |

  ## Per Problem Type

  ### {problem_type}
  Best: {best_technique} ({rate}%)
  Samples: {sample_count} ({sufficient/insufficient})

===============================================================
```

#### Types Mode

```
===============================================================
  PROBLEM TYPE STATISTICS
===============================================================

  | Type | Total Uses | Success Rate | Best Technique |
  |------|------------|--------------|----------------|
  | {type} | {uses} | {rate}% | {best_tech} |

  ## Details

  ### {type}
  - Uses: {total_uses}
  - Success: {success_count}
  - Failure: {failure_count}
  - Techniques used: {list}

===============================================================
```

#### Recent Mode

```
===============================================================
  RECENT ACTIVITY
===============================================================

  ## Last 10 Step Completions
  (Note: This mode shows recent activity from metrics)

  ## Classification Corrections
  (Note: Show recent corrections to learn from)

===============================================================
```

#### JSON Mode

Output raw JSON for scripting:
```python
import json
data = store.get_effectiveness_data()
print(json.dumps(data, indent=2))
```

### Step 3: Handle Empty Data

If no feedback data exists, show getting-started message:

```
===============================================================
  PLANNING SYSTEM FEEDBACK
===============================================================

  No feedback data collected yet.

  To start collecting data:
  1. Run /plan-feature to create a plan
  2. Run /plan-prompts to generate prompts
  3. Run /plan-next to execute steps

  After completing steps, feedback data will appear here.

  Minimum samples needed for recommendations: 10

===============================================================
```

## CLI Alternative

Run from command line:
```bash
python3 .claude/scripts/tangentle_plan.py feedback [mode]
```

## Trend Indicators

| Indicator | Meaning |
|-----------|---------|
| Up arrow | Recent success rate > overall by 5%+ |
| Right arrow | Stable (within 5%) |
| Down arrow | Recent success rate < overall by 5%+ |

## Data Thresholds

| Threshold | Value | Purpose |
|-----------|-------|---------|
| MIN_SAMPLES | 10 | Minimum samples for reliable recommendations |
| TREND_THRESHOLD | 5% | Change needed to show trend |

## Do NOT

- Modify any feedback data (this is read-only)
- Make recommendations with insufficient data
- Show misleading statistics
- Skip empty data handling
