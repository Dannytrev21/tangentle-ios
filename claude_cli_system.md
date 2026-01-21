# The complete guide to Claude Code CLI mastery

Claude Code is Anthropic's terminal-native agentic coding tool that gives developers direct, unopinionated access to Claude's capabilities through a command-line interface. Unlike IDE-integrated tools, Claude Code operates with a **200,000 token context window**, can autonomously read, write, and execute code, and integrates seamlessly with git workflows. The key to effective use lies in three pillars: strategic context management, plan-first workflows, and test-driven development. This guide synthesizes official documentation and community-validated practices into actionable patterns that produce high-quality, error-free code.

## Getting started requires minimal configuration but strategic setup

Installation is straightforward across platforms. On macOS and Linux, run `curl -fsSL https://claude.ai/install.sh | bash` or use Homebrew with `brew install --cask claude-code`. Windows users can use `irm https://claude.ai/install.ps1 | iex` or WinGet. After installation, navigate to your project directory and simply run `claude` to authenticate via OAuth or API key.

The first command you should run in any project is `/init`, which generates a `CLAUDE.md` file—the cornerstone of effective Claude Code usage. This file loads automatically at every session start and provides Claude with essential project context. Authentication options include direct API (`ANTHROPIC_API_KEY` environment variable), Amazon Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Google Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), or Microsoft Foundry.

**Configuration file hierarchy** matters significantly. Settings resolve in this order: `.claude/settings.local.json` (local, gitignored) → `.claude/settings.json` (project, team-shared) → `~/.claude/settings.json` (user global). For permissions, configure allowlists and denylists:

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test:*)"],
    "deny": ["Read(./.env)", "Read(./secrets/**)"]
  }
}
```

IDE integration enhances the experience substantially. The VS Code extension provides real-time diff viewing, extended thinking toggles, and keyboard shortcuts (`Cmd+Esc` to open, `Cmd+Option+K` for file references). JetBrains plugins support IntelliJ, PyCharm, WebStorm, and others with quick launch and diagnostic sharing features.

## The "explore, plan, code, commit" workflow produces reliable results

Experienced developers converge on a consistent pattern: **never let Claude jump straight to coding**. The Anthropic engineering team explicitly recommends this four-phase workflow, and community experience validates its effectiveness.

**Phase 1: Explore.** Ask Claude to read relevant files without writing code. Be explicit: "Read the authentication module and explain how sessions are managed. Don't write any code yet." This prevents premature solutions based on assumptions.

**Phase 2: Plan.** Enable Plan Mode by pressing `Shift+Tab` twice or using `/plan`. In this mode, Claude uses read-only tools and creates structured plans. Use thinking keywords to increase reasoning depth—"think" provides standard thinking, "think hard" increases it, "think harder" allocates more, and "**ultrathink**" allocates maximum budget (~31,999 tokens). Have Claude write the plan to a file: "Create a plan.md documenting the implementation approach."

**Phase 3: Code.** After approving the plan, switch back to normal mode and implement. Claude will follow the plan systematically. For complex changes, use the checklist pattern: "Run the lint command and write all errors to a Markdown checklist. Address each issue one by one, verifying and checking off before moving to next."

**Phase 4: Commit.** Claude handles git operations well—**90%+ of git interactions** can be delegated. Create custom slash commands for consistent PR workflows in `.claude/commands/pr.md`.

The community has discovered additional patterns that enhance this workflow. Harper Reed's "prompt plan" approach involves creating a `prompt_plan.md` file with ordered prompts, then instructing Claude to work through them systematically, marking each as completed. One developer reports completing greenfield development in "**30-45 minutes regardless of apparent complexity**" using this method.

## Context management separates productive sessions from frustrating ones

The **200,000 token context window** is both Claude Code's greatest strength and its primary constraint. Understanding context consumption enables strategic management.

A typical monorepo session starts with ~20,000 tokens for CLAUDE.md files and system prompts, leaving ~180,000 for work. Use `/context` to monitor usage. The critical thresholds are: **50-69%** (work normally), **70-84%** (consider `/compact`), **85-92%** (auto-compact may trigger), **93%+** (use `/clear`).

**Session management commands** provide control over context:
- `/clear` resets context completely—use between unrelated tasks
- `/compact` summarizes and condenses conversation history, reclaiming ~70% of space
- `claude --continue` or `-c` resumes the most recent conversation
- `claude --resume [id]` or `-r` resumes a specific session

For multi-day features, use the "**Document and Clear**" pattern: before ending a session, have Claude write progress to a file (`progress.md`), then `/clear` and start fresh with "Read progress.md and continue from where we left off." This prevents context degradation while maintaining continuity.

Claude Code's memory system operates through a hierarchy: enterprise policies (`/Library/Application Support/ClaudeCode/CLAUDE.md`) → user preferences (`~/.claude/CLAUDE.md`) → project level (`./CLAUDE.md`) → subdirectory-specific files. Use the import syntax `@path/to/file.md` to reference documentation without embedding it directly.

## CLAUDE.md configuration determines Claude's effectiveness

The CLAUDE.md file is loaded into every session automatically and shapes Claude's behavior. Community consensus and Anthropic guidance converge on specific best practices.

**Keep it under 300 lines**—shorter is better. HumanLayer's production CLAUDE.md is only ~60 lines. Prefer pointers over copies: instead of embedding code examples, write "See @docs/authentication.md for auth flow details." This keeps the base context lean while ensuring information remains accessible.

**Essential sections include**:
- Common bash commands (build, test, lint, with exact syntax)
- Code style guidelines (specific, not generic—"Use 2-space indentation" not "Format code properly")
- Architecture overview with directory structure
- Testing instructions and patterns to follow
- Critical warnings and gotchas

```markdown
# Project: MyApp
Next.js 14 with App Router, Prisma ORM, TypeScript strict mode

## Commands
- `npm run dev`: Start dev server (port 3000)
- `npm run test`: Run Jest tests (prefer single test files for speed)
- `npm run lint`: ESLint with auto-fix

## Code Style
- Named exports only, no default exports
- Early returns for guard clauses
- No `any` types—use proper generics

## Architecture
See @docs/architecture.md for full system design
- `/app`: Next.js pages and layouts
- `/lib`: Shared utilities (prefer composition over inheritance)

## Critical
- NEVER commit .env files
- Database migrations require team review
```

For monorepos, create **directory-specific CLAUDE.md files**: root level for common patterns, then `/frontend/CLAUDE.md`, `/backend/CLAUDE.md`, and `/shared/CLAUDE.md` for domain-specific context. Claude reads these automatically when accessing files in those directories.

Update CLAUDE.md from code reviews—when PR feedback catches convention violations, add the correction to prevent recurrence. Run CLAUDE.md through Claude's own prompt improver periodically to enhance adherence.

## Test-driven development dramatically improves code quality

The community consensus is emphatic: "**The robots LOVE TDD.**" Test-driven development provides Claude with verifiable objectives, eliminating ambiguity about success criteria and reducing hallucination significantly.

The TDD workflow with Claude Code follows a strict pattern:

1. **Write failing tests first**: "Write tests for the UserAuth module based on these expected input/output pairs. We're doing TDD—don't create mock implementations."
2. **Confirm tests fail**: "Run the tests and confirm they fail. Don't write any implementation code at this stage."
3. **Commit the tests**: "Commit these tests once you're satisfied with coverage."
4. **Implement to pass**: "Write code that passes the tests. Don't modify the tests. Keep going until all tests pass."
5. **Verify with subagent**: "Use a subagent to verify the implementation isn't overfitting to tests."
6. **Commit implementation**: "Commit the code once all tests pass."

Combine TDD with **pre-commit hooks** using the pre-commit package to run tests, linting, and type-checking before every commit. As one practitioner notes, "The robot REALLLLLY wants to commit"—hooks catch errors before they propagate.

For existing code modifications, enforce this rule in CLAUDE.md: "When modifying existing functions: ensure a unit test exists first, create one if none exists, then modify the function, then run tests to verify changes."

## All commands and modes serve distinct purposes

**Essential slash commands** every user should know:

| Command | Purpose |
|---------|---------|
| `/help` | Display all available commands |
| `/init` | Generate initial CLAUDE.md for project |
| `/plan` | Enable plan mode (read-only tools) |
| `/compact` | Compress conversation to save context |
| `/clear` | Reset conversation completely |
| `/rewind` | Revert to a previous checkpoint |
| `/resume` | Resume a previous conversation |
| `/context` | View context window usage |
| `/permissions` | Manage tool permissions |
| `/mcp` | Manage MCP server integrations |

**Operational modes** control Claude's autonomy level. Toggle with `Shift+Tab`:
- **Normal mode**: Prompts for approval on file edits and shell commands
- **Auto-Accept mode** (`--permission-mode acceptEdits`): Auto-approves file edits, prompts for other tools
- **Plan mode** (`--permission-mode plan`): Read-only exploration and planning
- **Bypass mode** (`--dangerously-skip-permissions`): Full autonomy—use only in isolated containers

**Custom slash commands** enable project-specific workflows. Create `.claude/commands/fix-issue.md`:

```markdown
---
allowed-tools: Read, Grep, Glob, Bash(git diff:*)
argument-hint: [issue-number]
description: Fix a GitHub issue
---
Fix issue #$ARGUMENTS by:
1. Using `gh issue view` to get details
2. Searching codebase for relevant files
3. Implementing necessary changes
4. Writing and running tests
5. Creating a PR with descriptive message
```

**Headless mode** (`-p` or `--print`) enables CI/CD integration and scripting:

```bash
# Simple query
claude -p "Explain what this codebase does"

# JSON output for parsing
claude -p "Generate code" --output-format json

# Pipeline usage
cat data.txt | claude -p "Summarize this data" > summary.txt

# In CI
claude -p "Fix lint errors and commit" --dangerously-skip-permissions
```

## Multi-agent patterns handle complex projects efficiently

Claude Code supports **native subagents** for specialized tasks. Three built-in agents exist: Explore (Haiku model, fast read-only exploration), Plan (Sonnet, research during plan mode), and General-purpose (Sonnet, full tool access for complex tasks).

Create custom subagents in `.claude/agents/code-reviewer.md`:

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use after writing code.
tools: Read, Grep, Glob, Bash
model: inherit
---
You are a senior code reviewer. Focus on:
1. Code quality and readability
2. Security vulnerabilities
3. Performance implications
4. Test coverage gaps
```

Invoke with: "Use the code-reviewer subagent to check my recent changes."

For **parallel multi-agent work**, git worktrees enable isolated contexts:

```bash
git worktree add ../project-feature-auth feature-auth
git worktree add ../project-feature-dashboard feature-dashboard

# Launch separate Claude instances in each
cd ../project-feature-auth && claude
cd ../project-feature-dashboard && claude
```

This pattern allows simultaneous frontend and backend development, complex refactoring alongside feature work, or having one Claude write code while another reviews.

The **dual Claude review pattern** produces higher quality: Claude A writes code, then `/clear` or open a new terminal, Claude B reviews the work, then Claude C (or another clear) implements the review feedback.

## Large codebase strategies prevent context exhaustion

For codebases larger than the context window, several strategies maintain effectiveness.

**Tiered CLAUDE.md structure** provides domain-specific context without bloating the base:

```
/repo
├── CLAUDE.md           # Common commands, high-level architecture
├── frontend/
│   └── CLAUDE.md       # React patterns, component conventions
├── backend/
│   └── CLAUDE.md       # API patterns, database conventions
└── shared/
    └── CLAUDE.md       # Shared types, utility patterns
```

**Semantic search via MCP** extends reach beyond the context window. Configure vector database integration in `.mcp.json`:

```json
{
  "mcpServers": {
    "context": {
      "command": "npx",
      "args": ["@zilliz/claude-context-mcp@latest"],
      "env": {
        "OPENAI_API_KEY": "your-key",
        "MILVUS_ADDRESS": "your-endpoint"
      }
    }
  }
}
```

This provides ~**40% token reduction** with equivalent retrieval quality and scales to millions of lines of code.

**Lazy loading documentation** keeps base context lean: instead of `@docs/testing.md` (which embeds the content), write "See docs/testing.md for testing guide"—Claude will read it when needed.

## CI/CD automation extends Claude Code beyond interactive use

GitHub Actions integration requires minimal setup. Run `/install-github-app` in Claude Code, then create `.github/workflows/claude-review.yml`:

```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
  issue_comment:
    types: [created]

jobs:
  claude:
    if: contains(github.event.comment.body, '@claude')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

This enables `@claude review this PR` comments to trigger automated code review, `@claude fix the formatting issues` to address feedback, and `@claude implement this feature` to convert issues to code.

For **automated CI failure fixes**:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    prompt: |
      The CI build failed with: ${{ steps.logs.outputs.result }}
      Fix the issues causing the build to fail.
      Focus on test failures, linting errors, type errors.
    auto_commit: true
    commit_message: 'fix: resolve CI failures'
```

**Security best practices** for automation: always use GitHub Secrets for API keys, restrict permissions with `--allowedTools`, only use `--dangerously-skip-permissions` in isolated containers, and configure appropriate timeouts.

## Recovery patterns handle mistakes gracefully

Claude Code provides robust recovery mechanisms. **Press Escape** to interrupt during any phase while preserving context—this enables immediate course correction. **Double-tap Escape** or use `/rewind` to access checkpoint history and revert to any previous state.

The `/rewind` command offers three recovery options: conversation only (rewind to a user message, keep code changes), code only (revert file changes, keep conversation), or both (restore both code and conversation).

When Claude makes errors, the most effective responses are:
1. Interrupt immediately with Escape
2. Provide explicit correction: "That approach won't work because X. Try Y instead."
3. Use `/rewind` to return before the mistake
4. Ask Claude to explain its reasoning: "Why did you make that change?"
5. Update CLAUDE.md to prevent recurrence

For critical work, **commit frequently**—Git is your safety net. Before risky modifications, create explicit checkpoints:

```bash
git add -A && git commit -m "checkpoint before refactoring"
# If Claude's changes don't work:
git reset --hard HEAD
```

## Conclusion: The patterns that matter most

Effective Claude Code usage reduces to a few core principles. **Always plan before coding**—the explore, plan, code, commit workflow consistently produces better results than letting Claude dive into implementation. **Manage context strategically**—use `/clear` between unrelated tasks, `/compact` when approaching limits, and external files for multi-session continuity.

**Invest in CLAUDE.md**—a well-crafted configuration file under 300 lines with specific conventions, pointer-style documentation references, and clear commands will compound in value across every session. **Embrace TDD**—providing Claude with verifiable objectives through tests eliminates ambiguity and dramatically reduces errors.

For advanced usage, **git worktrees enable parallel agents**, **custom subagents specialize for recurring tasks**, and **MCP integrations extend capabilities** to external services. In CI/CD, headless mode with appropriate permission restrictions automates code review, issue resolution, and maintenance tasks.

The developers reporting the highest productivity share a common approach: they treat Claude Code as a capable junior developer requiring clear specifications, explicit planning phases, and systematic verification—not as a magic wand that produces perfect code from vague requests.