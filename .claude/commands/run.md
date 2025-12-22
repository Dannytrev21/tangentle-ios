# Run Command

Build and run the Tangentle app on iOS Simulator.

## Input
Simulator name (optional): $ARGUMENTS

Default: iPhone 15

## Process

### Step 1: Verify Project Exists
```bash
ls Tangentle/Tangentle.xcodeproj
```

### Step 2: Determine Simulator
```bash
# List available simulators
xcrun simctl list devices available | grep -E "iPhone|iPad"
```

Use specified simulator or default to "iPhone 15".

### Step 3: Boot Simulator
```bash
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
```

### Step 4: Build for Simulator
```bash
cd Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" build
```

### Step 5: Install and Launch
```bash
# Get the app bundle path
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Tangentle.app" -path "*/Build/Products/*" | head -1)

# Install on simulator
xcrun simctl install booted "$APP_PATH"

# Launch the app
xcrun simctl launch booted com.tangentle.app
```

### Step 6: Open Simulator
```bash
open -a Simulator
```

### Step 7: Report Status
```
═══════════════════════════════════════════════════════════════
  🚀 APP RUNNING
═══════════════════════════════════════════════════════════════

Tangentle is running on {Simulator Name}

## Simulator Commands
- Press Cmd+Shift+H - Go to home screen
- Press Cmd+Shift+K - Toggle keyboard
- Cmd+S - Take screenshot

## Stop App
```bash
xcrun simctl terminate booted com.tangentle.app
```
```

## Examples
- `/run` - Run on iPhone 15
- `/run iPhone 15 Pro` - Run on specific device
- `/run iPad Pro (12.9-inch)` - Run on iPad
