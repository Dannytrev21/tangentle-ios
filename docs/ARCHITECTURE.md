# Tangentle Architecture

## Overview
Tangentle uses a layered architecture optimized for offline-first operation:

```
┌─────────────────────────────────────┐
│           SwiftUI Views             │
├─────────────────────────────────────┤
│           ViewModels                │
│         (@Observable)               │
├─────────────────────────────────────┤
│           Services                  │
│    (Business Logic Layer)           │
├─────────────────────────────────────┤
│         Repositories                │
│       (Data Access Layer)           │
├─────────────────────────────────────┤
│           Core Data                 │
│     (Persistence Layer)             │
└─────────────────────────────────────┘
```

## Key Patterns

### MVVM + Repository
- **Views**: SwiftUI, declarative UI
- **ViewModels**: @Observable classes, coordinate data and state
- **Services**: Business logic, cross-cutting concerns
- **Repositories**: Data access abstraction

### Dependency Injection
Manual DI container with:
- Protocol-based dependencies
- Lazy initialization
- SwiftUI Environment integration

### Offline-First
- Core Data for local storage
- CloudKit-compatible schema
- Background sync (future)

## Conventions

### Naming
- Views: `{Feature}View.swift`
- ViewModels: `{Feature}ViewModel.swift`
- Core Data entities: `TG{Entity}`
- Protocols: `{Name}Protocol`

### File Organization
Each feature module contains:
- Views (SwiftUI)
- ViewModels (@Observable)
- Feature-specific components
