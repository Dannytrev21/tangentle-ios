# Tangentle Data Model

## Core Data Entities

### TGTask
Primary task entity with full subtask support.

| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | Primary identifier |
| title | String | Task name |
| taskDescription | String? | Details |
| status | String | pending/in_progress/done/etc |
| priority | Int16 | 0-5 |
| estimatedDuration | Int16 | Minutes |
| scheduledDate | Date? | When to do |
| dueDate | Date? | Deadline |

**Relationships**: project, goal, subtasks, parentTask, blockedBy, tags

### TGProject
Container for tasks.

### TGGoal
Long-term objectives with linked projects.

### TGStrategy
Productivity strategies with scoring.

| Attribute | Type | Description |
|-----------|------|-------------|
| name | String | Strategy name |
| problemTypes | [String] | Applicable problem types |
| usageCount | Int32 | Times used |

**Scoring**: successRate × log(attempts + 1) × recencyFactor

### TGRoutine
Daily routines with ordered steps.

### TGHabit
Habit tracking with streaks.

### TGFocusMode
Context-based task filtering.

### TGMode
App configuration presets.

### TGProblemType
Avoidance problem definitions.

### TGTag
Task organization tags.

### TGSettings
User preferences (singleton).

## Entity Prefix
All Core Data entities use `TG` prefix to avoid conflicts with system types.

## CloudKit Compatibility
- UUID identifiers (no auto-increment)
- createdAt/updatedAt timestamps
- No unique constraints
- Transformable with secure coding
