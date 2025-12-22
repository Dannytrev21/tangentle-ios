# Build Command

Build the Tangentle iOS project.

## Process

### Step 1: Verify Project Exists
```bash
ls Tangentle/Tangentle.xcodeproj
```

If not found, inform user the Xcode project hasn't been created yet.

### Step 2: Run Build
```bash
cd Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1
```

### Step 3: Report Results

#### On Success
```
═══════════════════════════════════════════════════════════════
  ✅ BUILD SUCCEEDED
═══════════════════════════════════════════════════════════════

Build completed successfully.

## Next Steps
- `/test` - Run unit tests
- `/run` - Run on simulator
```

#### On Failure
```
═══════════════════════════════════════════════════════════════
  ❌ BUILD FAILED
═══════════════════════════════════════════════════════════════

## Errors Found
{List of errors with file:line}

## Common Fixes
1. Check for missing imports
2. Verify Core Data model compiles
3. Check for typos in entity names
```

Parse the xcodebuild output to extract:
- Errors (lines containing "error:")
- Warnings (lines containing "warning:")
- File locations

## Arguments
None - builds the main scheme
