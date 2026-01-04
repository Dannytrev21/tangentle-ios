# Repository Commands

> **Update Trigger**: When build, test, or run commands change. Auto-discovered during project setup.

## Quick Reference

| Action | Command |
|--------|---------|
| Build | `{build command}` |
| Test | `{test command}` |
| Lint | `{lint command}` |
| Run | `{run command}` |

## Build

```bash
# Full build
{build command}

# Clean build
{clean build command}

# Debug build
{debug build command}
```

## Test

```bash
# Run all tests
{test command}

# Run specific test file
{specific test command}

# Run with coverage
{coverage command}
```

### Test Types

| Type | Command | Location |
|------|---------|----------|
| Unit | `{unit test command}` | {path} |
| Integration | `{integration test command}` | {path} |
| E2E | `{e2e test command}` | {path} |

## Lint

```bash
# Run linter
{lint command}

# Auto-fix
{lint fix command}

# Check specific file
{lint file command}
```

## Format

```bash
# Format code
{format command}

# Check formatting
{format check command}
```

## Run

```bash
# Development mode
{dev run command}

# Production mode
{prod run command}
```

## Dependencies

```bash
# Install dependencies
{install command}

# Update dependencies
{update command}

# Add new dependency
{add dependency command}
```

## Other Commands

```bash
# Generate code
{codegen command}

# Database migrations
{migration command}

# Clean artifacts
{clean command}
```

---
*Auto-discovered on: {date}*
*Source: {package.json, Makefile, build.gradle, etc.}*
*Manual updates may be needed if build system changes.*
