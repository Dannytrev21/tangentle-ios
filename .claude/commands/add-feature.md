# Add Feature Command

Scaffold a new feature module in the Tangentle iOS app.

## Input
Feature name: $ARGUMENTS

## Process

### Step 1: Determine Feature Name
Convert input to proper naming:
- Feature folder name: `{FeatureName}` (PascalCase)
- View name: `{Feature}View`
- ViewModel name: `{Feature}ViewModel`

### Step 2: Verify Project Structure
```bash
ls Tangentle/Tangentle/Features/
```

### Step 3: Create Feature Directory
```bash
mkdir -p Tangentle/Tangentle/Features/{FeatureName}
```

### Step 4: Generate View
Create `Tangentle/Features/{Feature}/{Feature}View.swift`:

```swift
import SwiftUI

struct {Feature}View: View {
    @Environment(\.container) var container
    @State private var viewModel: {Feature}ViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    {Feature}Content(viewModel: vm)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("{Feature}")
        }
        .task {
            viewModel = {Feature}ViewModel(
                // Inject dependencies from container
            )
            await viewModel?.load()
        }
    }
}

struct {Feature}Content: View {
    @Bindable var viewModel: {Feature}ViewModel

    var body: some View {
        List {
            // TODO: Implement feature UI
            Text("Feature: {Feature}")
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

#Preview {
    {Feature}View()
        .withContainer(TestContainer())
}
```

### Step 5: Generate ViewModel
Create `Tangentle/Features/{Feature}/{Feature}ViewModel.swift`:

```swift
import Foundation
import Observation

@Observable
final class {Feature}ViewModel {
    var isLoading = false
    var error: Error?

    // Add dependencies as needed
    // private let someService: SomeServiceProtocol

    init(/* dependencies */) {
        // Store dependencies
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TODO: Load data
        } catch {
            self.error = error
        }
    }
}
```

### Step 6: Output Summary
```
═══════════════════════════════════════════════════════════════
  ✅ FEATURE CREATED: {Feature}
═══════════════════════════════════════════════════════════════

## Files Created
- `Features/{Feature}/{Feature}View.swift`
- `Features/{Feature}/{Feature}ViewModel.swift`

## Next Steps

1. **Add to navigation**
   Update `App/ContentView.swift` to include the new feature tab or navigation.

2. **Inject dependencies**
   Update the ViewModel init to accept required services:
   ```swift
   init(someService: SomeServiceProtocol) {
       self.someService = someService
   }
   ```

3. **Wire in Container**
   Update the View's .task to inject from container:
   ```swift
   viewModel = {Feature}ViewModel(
       someService: container.someService
   )
   ```

4. **Implement UI**
   Build out the feature's user interface in {Feature}Content.

5. **Add tests**
   Create `TangentleTests/Unit/{Feature}ViewModelTests.swift`

## Build
`/build` to verify compilation
```

## Examples
- `/add-feature Notes`
- `/add-feature Timer`
- `/add-feature Analytics`
