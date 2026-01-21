# Context Management Guide

Claude Code has a **200,000 token context window**. Strategic management is essential for productive sessions.

## Context Consumption

A typical monorepo session starts with ~20,000 tokens for CLAUDE.md files and system prompts, leaving ~180,000 for work.

### Monitoring
Use `/context` to check current usage percentage.

### Critical Thresholds

| Usage | Status | Action |
|-------|--------|--------|
| 50-69% | Normal | Work normally |
| 70-84% | Caution | Consider `/compact` |
| 85-92% | Warning | Auto-compact may trigger |
| 93%+ | Critical | Use `/clear` |

## Session Commands

### /clear
Resets context completely. Use:
- Between unrelated tasks
- When starting fresh work
- When context is critical (93%+)

### /compact
Summarizes and condenses conversation history, reclaiming ~70% of space. Use:
- When approaching limits (70-84%)
- To preserve some context while freeing space
- Before starting a new phase of work

### /context
View current context window usage. Check periodically during long sessions.

### Resuming Sessions
```bash
claude --continue    # Resume most recent conversation
claude -c            # Short form

claude --resume [id] # Resume specific session
claude -r [id]       # Short form
```

## Multi-Day Work: Document and Clear

For features spanning multiple sessions, use this pattern:

### Before Ending Session
1. Have Claude write progress to a file:
   ```
   Write our progress to progress.md including:
   - What's completed
   - Current state
   - Next steps
   - Any blockers or decisions made
   ```

2. Commit the progress file:
   ```bash
   git add progress.md && git commit -m "progress: session checkpoint"
   ```

3. Use `/clear` to reset context

### Resuming Next Session
```
Read progress.md and continue from where we left off.
```

This prevents context degradation while maintaining continuity.

## Memory Hierarchy

Claude Code's memory loads in order (later overrides earlier):

1. **Enterprise policies**: `/Library/Application Support/ClaudeCode/CLAUDE.md`
2. **User preferences**: `~/.claude/CLAUDE.md`
3. **Project level**: `./CLAUDE.md`
4. **Subdirectory**: `./frontend/CLAUDE.md`, etc.

### Import Syntax
Reference documentation without embedding:
```markdown
See @docs/authentication.md for auth flow details.
```

Claude reads the file when needed rather than loading it all upfront.

### Lazy Loading
Instead of `@docs/testing.md` (embeds content), write:
> "See docs/testing.md for testing guide"

Claude reads it only when relevant.

## Strategies for Large Codebases

### Tiered CLAUDE.md
Keep base CLAUDE.md lean, add domain-specific files:
```
/repo
├── CLAUDE.md           # ~60-100 lines, common patterns
├── frontend/CLAUDE.md  # Frontend conventions
├── backend/CLAUDE.md   # Backend conventions
└── shared/CLAUDE.md    # Shared utilities
```

### Focused Tasks
- Break large features into smaller, focused tasks
- `/clear` between different areas of work
- Use specific file references instead of broad searches

### Semantic Search (Advanced)
For very large codebases, configure MCP vector search to find relevant code without loading everything.

## Planning System Integration

The intelligent planning system helps manage context:

### Step-Based Work
Each plan step is designed to be completable in a single session. If context runs low:
1. Check progress with `/plan-status`
2. Document state in `context.md`
3. `/clear` and resume with `/plan-next`

### Context.md File
Each plan has a `context.md` that tracks:
- Current step and status
- Key decisions made
- Files created/modified
- Session notes

This enables seamless continuation across sessions.

See also:
- `claude-code-mastery.md` for overall workflow
- `thinking-keywords.md` for controlling reasoning depth
