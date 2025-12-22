# Step 3: Core Data Models

## Context
This is the most critical step - defining the Core Data model that underlies all app functionality. We're porting domain concepts from executive-brain (tasks, projects, strategies, etc.) to a Core Data schema optimized for iOS and CloudKit compatibility.

## Goal
Create a complete Core Data model (`.xcdatamodeld`) with all entities, attributes, and relationships defined. The model should compile without errors and be CloudKit-compatible.

## Prerequisites
- Step 1 completed (Xcode project exists)

## High-Level Steps
1. Create Core Data model file
2. Define all entities with attributes
3. Configure relationships between entities
4. Set up indexes for common queries
5. Configure CloudKit compatibility settings

## Detailed Requirements

### Entities to Create

#### TGTask
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary identifier |
| title | String | No | Task name |
| taskDescription | String | Yes | Detailed description |
| status | String | No | Default: "pending" |
| priority | Integer 16 | No | 0-5, default 0 |
| estimatedDuration | Integer 16 | No | Minutes, default 30 |
| scheduledDate | Date | Yes | When to do it |
| scheduledTime | Date | Yes | Specific time |
| dueDate | Date | Yes | Hard deadline |
| startDate | Date | Yes | When to start showing |
| completedAt | Date | Yes | When completed |
| energyRequired | String | No | low/medium/high |
| createdAt | Date | No | Creation timestamp |
| updatedAt | Date | No | Last update |
| sortOrder | Integer 32 | No | For ordering |

**Relationships:**
- `project` → TGProject (to-one, optional)
- `goal` → TGGoal (to-one, optional)
- `routine` → TGRoutine (to-one, optional)
- `parentTask` → TGTask (to-one, optional, self-referential)
- `subtasks` → TGTask (to-many, inverse of parentTask)
- `focusMode` → TGFocusMode (to-one, optional)
- `tags` → TGTag (to-many)
- `blockedBy` → TGTask (to-many, tasks this depends on)
- `blocking` → TGTask (to-many, inverse)
- `linkedStrategies` → TGStrategy (to-many)

#### TGProject
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary identifier |
| name | String | No | Project name |
| emoji | String | Yes | Visual identifier |
| color | String | Yes | Hex color |
| projectDescription | String | Yes | Description |
| isActive | Boolean | No | Default true |
| sortOrder | Integer 32 | No | For ordering |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `tasks` → TGTask (to-many, cascade delete)
- `goal` → TGGoal (to-one, optional)
- `focusModes` → TGFocusMode (to-many)

#### TGGoal
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| goalDescription | String | Yes | |
| targetDate | Date | Yes | |
| isActive | Boolean | No | Default true |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `projects` → TGProject (to-many)
- `tasks` → TGTask (to-many)

#### TGStrategy
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| strategyDescription | String | No | |
| problemTypes | Transformable | No | [String] array |
| taskTypes | Transformable | No | [String] array |
| tags | Transformable | Yes | [String] array |
| tweaks | Transformable | Yes | [String] array |
| source | String | No | "user" or "default" |
| isActive | Boolean | No | Default true |
| usageCount | Integer 32 | No | Default 0 |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `outcomes` → TGStrategyOutcome (to-many, cascade delete)
- `linkedTasks` → TGTask (to-many)

#### TGStrategyOutcome
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| date | Date | No | |
| result | String | No | success/partial/failure |
| problemType | String | No | |
| taskType | String | No | |
| taskTitle | String | No | |
| notes | String | Yes | |

**Relationships:**
- `strategy` → TGStrategy (to-one, required)

#### TGRoutine
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| routineDescription | String | Yes | |
| scheduledTime | Date | No | Time of day |
| estimatedDuration | Integer 16 | No | Minutes |
| daysOfWeek | Transformable | No | [String] array |
| isEnabled | Boolean | No | Default true |
| routineType | String | No | morning/evening/etc |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `steps` → TGRoutineStep (to-many, ordered, cascade delete)
- `linkedTasks` → TGTask (to-many)

#### TGRoutineStep
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| estimatedDuration | Integer 16 | No | |
| sortOrder | Integer 32 | No | |

**Relationships:**
- `routine` → TGRoutine (to-one, required)

#### TGHabit
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| habitDescription | String | Yes | |
| frequency | String | No | daily/weekly |
| targetCount | Integer 16 | No | Default 1 |
| isActive | Boolean | No | Default true |
| streakCount | Integer 32 | No | Default 0 |
| lastCompletedAt | Date | Yes | |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `completions` → TGHabitCompletion (to-many, cascade delete)

#### TGHabitCompletion
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| date | Date | No | |
| count | Integer 16 | No | Default 1 |

**Relationships:**
- `habit` → TGHabit (to-one, required)

#### TGFocusMode
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| focusModeDescription | String | Yes | |
| startTime | Date | Yes | |
| endTime | Date | Yes | |
| daysOfWeek | Transformable | Yes | [String] |
| isActive | Boolean | No | Default true |
| isAutomatic | Boolean | No | Default false |
| filterTags | Transformable | Yes | [String] |
| sortOrder | Integer 32 | No | |
| createdAt | Date | No | |
| updatedAt | Date | No | |

**Relationships:**
- `includedProjects` → TGProject (to-many)
- `tasks` → TGTask (to-many)

#### TGMode
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| modeDescription | String | Yes | |
| settings | Binary Data | No | JSON blob |
| isDefault | Boolean | No | Default false |
| isShared | Boolean | No | Default false |
| createdAt | Date | No | |
| updatedAt | Date | No | |

#### TGProblemType
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| identifier | String | No | too_big, unclear, etc |
| label | String | No | Display name |
| problemTypeDescription | String | No | |
| suggestedStrategyIds | Transformable | Yes | [String] |
| isDefault | Boolean | No | Default false |
| sortOrder | Integer 32 | No | |

#### TGTag
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| name | String | No | |
| color | String | Yes | |
| sortOrder | Integer 32 | No | |

**Relationships:**
- `tasks` → TGTask (to-many)

#### TGSettings (singleton)
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | |
| scheduleSettings | Binary Data | Yes | JSON |
| taskSettings | Binary Data | Yes | JSON |
| displaySettings | Binary Data | Yes | JSON |
| coachingSettings | Binary Data | Yes | JSON |
| updatedAt | Date | No | |

### CloudKit Compatibility
- All entities use UUID for `id` (not auto-increment)
- All entities have `createdAt` and `updatedAt`
- No unique constraints (conflicts with sync)
- Use `Transformable` with `NSSecureUnarchiveFromData` transformer

### Indexes
Create indexes on frequently queried attributes:
- TGTask: `scheduledDate`, `status`, `priority`
- TGProject: `isActive`
- TGStrategy: `isActive`

## Files to Create
- `Tangentle/Data/Tangentle.xcdatamodeld`

## Files to Modify
- None

## Patterns to Follow
Use standard Core Data patterns:
- UUID for identifiers
- Transformable for arrays
- Binary Data for JSON blobs
- Ordered relationships where sequence matters

## Acceptance Criteria
- [ ] Core Data model file exists in Data/ folder
- [ ] All 14 entities defined with correct attributes
- [ ] All relationships configured with correct cardinality
- [ ] Delete rules set appropriately (cascade where needed)
- [ ] Project builds without Core Data warnings
- [ ] Transformable attributes use secure transformer

## Verification Commands
```bash
# Build project to verify model compiles
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | grep -E "(error|warning:.*xcdatamodel)"

# Verify model file exists
ls -la tangentle-ios/Tangentle/Tangentle/Data/Tangentle.xcdatamodeld
```

## Documentation Updates
- [ ] Update docs/DATA-MODEL.md with final entity definitions

## Error Recovery
If model won't compile:
1. Check for missing inverse relationships
2. Verify Transformable transformer is set
3. Check for circular required relationships
4. Open model in Xcode editor and validate

## Do NOT
- Use auto-increment IDs (breaks CloudKit)
- Create unique constraints (breaks sync)
- Mark relationships as required unless truly mandatory
- Forget inverse relationships
