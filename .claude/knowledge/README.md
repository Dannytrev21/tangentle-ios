# Claude Code Knowledge Base

This directory contains modular reference documents extracted from the Claude Code CLI mastery guide. These files provide focused, easily-loadable context for different aspects of Claude Code usage.

## Purpose

Instead of embedding all context in CLAUDE.md, these files can be:
- Referenced via `@.claude/knowledge/filename.md` syntax
- Loaded on-demand when specific guidance is needed
- Kept under 200 lines each for efficient context usage

## Files

| File | Content | When to Reference |
|------|---------|-------------------|
| `claude-code-mastery.md` | Core workflow patterns, recovery, git strategies | General guidance, workflow questions |
| `thinking-keywords.md` | Thinking depth control with risk mapping | Planning steps, complex reasoning |
| `context-management.md` | Token management, session commands | Long sessions, context warnings |
| `tdd-patterns.md` | Test-driven development workflow | Writing tests, implementation |

## Usage in CLAUDE.md

Reference these files using the import syntax:

```markdown
## Extended Reference
See @.claude/knowledge/claude-code-mastery.md for core workflow patterns.
See @.claude/knowledge/thinking-keywords.md for reasoning depth guidance.
See @.claude/knowledge/context-management.md for session management.
See @.claude/knowledge/tdd-patterns.md for TDD workflow.
```

## Usage in Prompts

Reference specific files when needed:

```markdown
Before implementing, read @.claude/knowledge/tdd-patterns.md and follow the TDD workflow.
```

## Maintenance

- Each file should stay under 200 lines
- Content should be extracted from official guides, not invented
- Cross-reference related files rather than duplicating content
- Update when official guidance changes
