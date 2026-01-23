# Claude Code Mastery Patterns

Core patterns from the Claude Code CLI mastery guide for effective development.

## The "Explore, Plan, Code, Commit" Workflow

**Never let Claude jump straight to coding.** This four-phase workflow produces reliable results.

### Phase 1: Explore
Ask Claude to read relevant files without writing code. Be explicit:
> "Read the authentication module and explain how sessions are managed. Don't write any code yet."

This prevents premature solutions based on assumptions.

### Phase 2: Plan
- Enable Plan Mode with `Shift+Tab` twice or `/plan`
- In this mode, Claude uses read-only tools and creates structured plans
- Use thinking keywords for complex planning (see `thinking-keywords.md`)
- Have Claude write the plan to a file: "Create a plan.md documenting the implementation approach."

### Phase 3: Code
After approving the plan, switch back to normal mode and implement. Claude follows the plan systematically.

For complex changes, use the checklist pattern:
> "Run the lint command and write all errors to a Markdown checklist. Address each issue one by one, verifying and checking off before moving to next."

### Phase 4: Commit
Claude handles git operations well. **90%+ of git interactions** can be delegated.

## CLAUDE.md Best Practices

**Keep it under 300 lines**—shorter is better. HumanLayer's production CLAUDE.md is only ~60 lines.

### Prefer Pointers Over Copies
Instead of embedding code examples:
> "See @docs/authentication.md for auth flow details."

This keeps the base context lean.

### Essential Sections
- Common bash commands (build, test, lint with exact syntax)
- Code style guidelines (specific, not generic)
- Architecture overview with directory structure
- Testing instructions and patterns
- Critical warnings and gotchas

### Directory-Specific CLAUDE.md
For monorepos, create nested files:
```
/repo
├── CLAUDE.md           # Common commands, high-level architecture
├── frontend/CLAUDE.md  # React patterns, component conventions
├── backend/CLAUDE.md   # API patterns, database conventions
└── shared/CLAUDE.md    # Shared types, utility patterns
```

## Recovery Patterns

### Escape Key
- **Single Escape**: Interrupt during any phase while preserving context
- **Double Escape** or `/rewind`: Access checkpoint history

### /rewind Options
1. **Conversation only**: Rewind to a user message, keep code changes
2. **Code only**: Revert file changes, keep conversation
3. **Both**: Restore both code and conversation

### When Claude Makes Errors
1. Interrupt immediately with Escape
2. Provide explicit correction: "That approach won't work because X. Try Y instead."
3. Use `/rewind` to return before the mistake
4. Ask Claude to explain: "Why did you make that change?"
5. Update CLAUDE.md to prevent recurrence

## Git Patterns

### Commit Frequently
- Git is your safety net
- Create checkpoints before risky operations
- The robot REALLLLLY wants to commit - let it

### Commit Message Convention
Use semantic prefixes:
- `checkpoint:` - Before risky operations
- `progress:` - Partial completion
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `docs:` - Documentation

### Pre-Commit Hooks
- Use hooks to enforce quality
- Catches errors before they propagate
- Works well with Claude's commit enthusiasm

### Worktrees for Parallel Work
- Multiple Claude sessions on different branches
- Useful for complex plans
- Each worktree is isolated
- Enables parallel frontend/backend development

### Recovery Patterns
- `/rewind` for conversation recovery
- `git reset` for code recovery
- Checkpoint commits enable easy rollback

### Dual Claude Review Pattern
For higher quality:
1. Claude A writes code
2. `/clear` or open new terminal
3. Claude B reviews the work
4. Claude C implements review feedback

See @.claude/commands/plan-prompts.md for full git workflow documentation including commands and worktree examples.

## Core Principles Summary

1. **Always plan before coding** - explore, plan, code, commit
2. **Manage context strategically** - `/clear` between tasks, `/compact` when approaching limits
3. **Invest in CLAUDE.md** - under 300 lines, specific conventions, pointer-style references
4. **Embrace TDD** - tests eliminate ambiguity (see `tdd-patterns.md`)
5. **Treat Claude as a capable junior developer** - clear specs, explicit planning, systematic verification

See also:
- `thinking-keywords.md` for reasoning depth control
- `context-management.md` for session management
- `tdd-patterns.md` for TDD workflow
