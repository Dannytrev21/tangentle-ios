# Step 1: Project Setup

## Context
This is the first step of the Tangentle iOS foundation. We need to create the Xcode project with the correct folder structure, bundle identifier, and initial configuration. This establishes the skeleton for all subsequent steps.

## Goal
Create a working Xcode project with proper folder organization that compiles and runs on simulator.

## Prerequisites
- Xcode 15.0+ installed
- macOS Sonoma or later
- Apple Developer account (for device testing later)

## High-Level Steps
1. Create Xcode project with SwiftUI lifecycle
2. Configure project settings (bundle ID, version, deployment target)
3. Create folder structure matching architecture plan
4. Add .gitignore appropriate for iOS/Xcode
5. Initial git commit

## Detailed Requirements

### Project Configuration
- **Product Name**: Tangentle
- **Bundle Identifier**: com.tangentle.app
- **Deployment Target**: iOS 17.0
- **Interface**: SwiftUI
- **Lifecycle**: SwiftUI App
- **Language**: Swift
- **Include Tests**: Yes (Unit and UI)

### Folder Structure
Create this hierarchy inside the Xcode project:
```
Tangentle/
├── App/                      # App lifecycle
├── Core/
│   ├── Models/              # Domain model extensions
│   ├── Services/            # Business logic
│   ├── Repositories/        # Data access
│   ├── Utilities/           # Helpers
│   └── DI/                  # Dependency injection
├── Features/
│   ├── Tasks/
│   ├── Projects/
│   ├── Goals/
│   ├── Calendar/
│   ├── Routines/
│   ├── Habits/
│   ├── Strategies/
│   ├── FocusModes/
│   ├── Modes/
│   └── Settings/
├── UI/
│   ├── Components/
│   ├── Themes/
│   └── Gestures/
├── Data/                    # Core Data will go here
└── Resources/
```

### Initial Files
- `App/TangentleApp.swift` - App entry point
- `App/ContentView.swift` - Initial view (placeholder)

## Files to Create
- Xcode project at `tangentle-ios/Tangentle/`
- All folder groups within Xcode
- `.gitignore` at project root

## Files to Modify
- None (new project)

## Patterns to Follow
Standard SwiftUI App lifecycle pattern.

## Acceptance Criteria
- [ ] Xcode project opens without errors
- [ ] Project builds successfully (Cmd+B)
- [ ] App runs on iOS 17 simulator
- [ ] All folder groups visible in Xcode navigator
- [ ] Bundle identifier is `com.tangentle.app`
- [ ] Deployment target is iOS 17.0
- [ ] Git repository initialized with .gitignore
- [ ] Initial commit created

## Verification Commands
```bash
# Verify project exists
ls -la tangentle-ios/Tangentle/Tangentle.xcodeproj

# Build project from command line
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build

# Verify git setup
cd tangentle-ios && git status
```

## Documentation Updates
- [ ] None for this step (docs created in step 2)

## Error Recovery
If project creation fails:
1. Delete the Tangentle folder
2. Recreate using Xcode File > New > Project
3. Verify Xcode version is 15.0+

If build fails:
1. Check deployment target matches iOS 17.0
2. Verify no syntax errors in generated files
3. Clean build folder (Cmd+Shift+K)

## Do NOT
- Add any external dependencies (SPM packages) yet
- Create Core Data model yet (that's step 3)
- Add any business logic
- Configure CloudKit or signing (not needed for foundation)
