---
trigger: glob
glob: .windsurf/**
description: Prevent Windsurf planning files from being staged or committed
---

# Do Not Stage .windsurf Files

Files in `.windsurf/` are local to your workspace and should NOT be committed to git.

## What's in .windsurf/
- `plans/` - Implementation plans and progress
- `rules/` - Cascade customization rules
- `scripts/` - Python utilities
- `workflows/` - Command definitions
- `templates/` - Artifact templates
- `knowledge/` - Reference documentation
- `memory-bank/` - Session context

## If You See .windsurf in Staging

```bash
# Unstage
git reset .windsurf/

# Verify .gitignore has entry
grep ".windsurf" .gitignore

# Add if missing
echo ".windsurf/**" >> .gitignore
```

**Never commit .windsurf files to the repository.**
