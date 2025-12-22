# Help Command

Show available commands and their usage.

## Output

```
═══════════════════════════════════════════════════════════════
  TANGENTLE iOS COMMANDS
═══════════════════════════════════════════════════════════════

## Build & Run
| Command | Description |
|---------|-------------|
| /build | Build the Xcode project |
| /test [suite] | Run tests (all or specific suite) |
| /run [simulator] | Run app on simulator |

## Planning System
| Command | Description |
|---------|-------------|
| /plan-feature {desc} | Create new implementation plan |
| /plan-prompts {#} | Generate AI prompts for plan |
| /plan-next {#} | Execute next step in plan |
| /plan-status [#] | Check plan progress |
| /plan-verify {#} | Re-run verification |
| /plan-rollback {#} | Rollback failed step |

## Code Generation
| Command | Description |
|---------|-------------|
| /add-entity {desc} | Add Core Data entity |
| /add-feature {name} | Scaffold feature module |

## Current Plans
Run `/plan-status` to see all plans and their progress.

## Quick Reference

### Build Commands
```bash
# Build from command line
cd Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Run tests
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Project Structure
```
Tangentle/
├── App/           # App lifecycle
├── Core/          # Business logic
├── Features/      # Feature modules
├── UI/            # Reusable components
├── Data/          # Core Data
└── Resources/     # Assets
```

### Documentation
- `CLAUDE.md` - Development instructions
- `docs/ARCHITECTURE.md` - Architecture details
- `docs/DATA-MODEL.md` - Entity documentation
═══════════════════════════════════════════════════════════════
```
