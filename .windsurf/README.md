# Windsurf Planning System

AI-assisted step-by-step feature implementation with intelligent technique selection.

## What This Is

A planning system that breaks down complex features into manageable steps, applies appropriate AI techniques to each step, and tracks progress with self-correction on failures.

**Key Features**:
- Automatic problem classification (33 types, 8 categories)
- Technique selection per phase (10 techniques)
- Self-correction with memory bank
- Progress tracking with git integration
- Never commits .windsurf/** to git

## Quick Start

```
/plan-feature-initial Add a new feature
# Answer questions...

/plan-feature Add a new feature [with spec]

/plan-prompts 001

/plan-next 001
# Implement, verify, commit

/plan-status 001
```

See: [QUICK_START.md](QUICK_START.md)

## Directory Structure

```
.windsurf/
├── workflows/           # Cascade commands (/plan-*)
├── plans/               # Implementation plans
│   └── 001-feature/
│       ├── plan.md      # Main plan document
│       ├── adr.md       # Architecture decisions
│       ├── steps/       # Step specifications
│       ├── prompts/     # AI prompts per step
│       ├── progress.json
│       └── context.md
├── scripts/             # Python utilities
│   └── tests/           # Unit tests
├── templates/           # Artifact templates
├── knowledge/           # Reference docs
│   └── techniques/      # Technique guides
├── memory-bank/         # Cross-session context
└── rules/               # Custom rules
```

## Commands

| Command | Purpose |
|---------|---------|
| `/plan-feature-initial` | Gather requirements |
| `/plan-feature` | Create plan |
| `/plan-prompts` | Generate AI prompts |
| `/plan-next` | Execute next step |
| `/plan-status` | View progress |
| `/plan-verify` | Re-run verification |
| `/plan-rollback` | Undo step changes |
| `/plan-feature-review` | Analyze plan quality |

See: [COMMAND_REFERENCE.md](COMMAND_REFERENCE.md)

## Techniques

The system automatically selects techniques based on problem type:

| Technique | Best For |
|-----------|----------|
| ToT (Tree of Thoughts) | Complex decisions |
| GoT (Graph of Thoughts) | Merging ideas |
| TDD | Code with tests |
| Reflexion | Learning from failures |
| Self-Refine | Iterative improvement |
| ReAct | Interactive problems |
| Self-Consistency | Algorithm verification |
| Chain-of-Code | Mixed logic/semantic |
| PS+ | Structured planning |
| Least-to-Most | Decomposition |

## Self-Correction

When steps fail, the system:
1. Retries with the same technique (based on risk level)
2. Rotates to alternative techniques
3. Escalates if all retries exhausted

Memory bank stores lessons learned (FIFO, max 10 per plan).

## Not Committed

Everything in `.windsurf/` stays local:
- Plans and progress
- Memory bank entries
- Context files

Your `.gitignore` should contain:
```
.windsurf/**
```

## Documentation

- [INSTALL.md](INSTALL.md) - Installation guide
- [QUICK_START.md](QUICK_START.md) - First plan tutorial
- [COMMAND_REFERENCE.md](COMMAND_REFERENCE.md) - All commands
- [MIGRATION_FROM_CLAUDE.md](MIGRATION_FROM_CLAUDE.md) - Claude Code migration
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

## CLI Tools

```bash
python3 .windsurf/scripts/windsurf_plan.py --help
python3 .windsurf/scripts/windsurf_plan.py classify "description"
python3 .windsurf/scripts/windsurf_plan.py techniques problem-type
python3 .windsurf/scripts/windsurf_plan.py risk problem-type
python3 .windsurf/scripts/windsurf_plan.py list
python3 .windsurf/scripts/windsurf_plan.py status 001
```

## Testing

```bash
# Run all tests
python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py'

# Check installation
python3 .windsurf/scripts/windsurf_plan.py --help
```
