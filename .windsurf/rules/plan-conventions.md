---
trigger: always_on
description: Core conventions for the Windsurf planning system
---

# Planning System Conventions

## Question Categories for Requirements Analysis

When gathering requirements, check these areas for gaps:

### Scope
- Minimum viable version (MVP)
- Features explicitly excluded
- Phasing (v1 vs v2)
- Existing features affected

### User Experience
- Primary user flow
- Gestures/interactions expected
- Accessibility requirements
- Error state handling

### Data
- New entities/models needed
- Existing data consumed
- Storage location (local/cloud)
- Sync strategy

### Technical
- Platform/version requirements
- Dependencies acceptable
- Performance targets
- Offline behavior

### Visual Design
- Design spec or reference available
- Reusable components
- New components needed
- Dark mode requirements

### Integration
- Existing services involved
- APIs consumed/exposed
- Third-party integrations
- Background processing needs

### Testing
- Coverage level expected
- Manual testing required
- Edge cases to handle
- Devices to test

### Rollout
- Feature flagging needed
- Migration strategy
- Rollback plan
- Analytics requirements

## Quality Standards

### For Steps
- Completable in 30-90 minutes
- Clear, testable acceptance criteria
- Explicit dependencies
- Copy-pasteable verification commands
- **Every step MUST include tests**

### For Testing
- Unit tests for all new functions/methods
- Integration tests when components interact
- UI tests for user-facing features
- Test naming: `test{What}_when{Condition}_should{Expected}()`

### For Context Preservation
- Write as if explaining to someone with no prior context
- Include specific file paths and line numbers
- Document "why" not just "what"
- Update after every significant change

## Risk Levels

| Level | Same Tech | Alt Tech | Total | When to Use |
|-------|-----------|----------|-------|-------------|
| Low | 2 | 1 | 3 | Simple, low-impact changes |
| Medium | 3 | 2 | 5 | Standard implementation |
| High | 3 | 3 | 7 | Complex or breaking changes |
| Critical | 4 | 4 | 10 | Data migration, core systems |
