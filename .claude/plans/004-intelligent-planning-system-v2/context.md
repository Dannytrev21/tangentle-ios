# Plan 004 Context

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: Intelligent Planning System v2
- **Current Step**: 8b - Prompt Embedding
- **Last Updated**: 2025-12-31
- **Last Review**: 2025-12-24 (Score: 36/50)
- **Progress**: 8/15 steps complete (53%)

## What's Been Done
- Plan created with full Tree of Thought analysis
- 15 implementation steps defined (originally 14, Step 8 split into 8a/8b)
- Technique mapping matrix designed
- Risk assessment strategy defined
- All step files created with detailed requirements
- Plan review completed (36/50 score)
- Step 8 split into 8a (Template Extraction) and 8b (Prompt Embedding)
- **Step 1 Complete**: Technique Config Schema created
- **Step 2 Complete**: Problem Classifier Script implemented
- **Step 3 Complete**: Technique Selector Script implemented
- **Step 4 Complete**: Risk Assessor Script implemented
- **Step 5 Complete**: CLI Orchestrator implemented
- **Step 6 Complete**: plan-feature-initial updated with classification
- **Step 7 Complete**: plan-feature updated with technique assignment per step
- **Step 8a Complete**: Template parser created, section markers added to all 10 technique files

## Problem Type Taxonomy (Finalized)

### Categories and Subtypes
```
FOUNDATION
├── infrastructure
├── scaffolding
└── configuration

DATA
├── data-modeling
├── data-access
├── migration
└── state-mgmt

ARCHITECTURE
├── system-design
├── protocol-design
├── di-setup
├── service-impl
└── refactor

UI/UX
├── ui
├── component-lib
├── design-tokens
├── animation
├── gesture
├── accessibility
└── polish

TESTING
├── test-setup
├── unit-test
├── integration-test
├── snapshot-test
├── e2e-test
└── performance-test

LOGIC
├── algorithm
├── validation
├── api-integration
└── debug

DOCUMENTATION
├── documentation
└── changelog

META
├── ideation
└── new-feature
```

## Technique Mapping Summary

| Phase | Low Complexity | High Complexity |
|-------|----------------|-----------------|
| Planning | PS+, ReAct | ToT, GoT |
| Implementation | Self-Refine | TDD + Reflexion |
| Verification | Self-Refine, TDD | Reflexion, Self-Consistency |

## Files Created
| File | Purpose |
|------|---------|
| plan.md | Main plan with technique matrix |
| adr.md | Architecture decisions |
| steps/01-14, 08a, 08b | 15 step specification files |
| progress.json | Progress with technique metadata |
| context.md | This file |
| reviews/review-2025-12-24.md | First plan review |

## Files Modified
| File | Changes |
|------|---------|
| progress.json | Updated with Step 1 completion |
| context.md | Added Step 1 completion details |

## Key Decisions Made
1. **Hybrid classification**: LLM auto-detects, user confirms
2. **Phase-based composition**: Different techniques for plan/implement/verify
3. **Risk-based retries**: Low-risk=3, Medium=5, High=7, Critical=10
4. **Python scripts**: Called by markdown commands for complex logic
5. **JSON config**: Technique mappings in `.claude/technique-config.json`

## Architecture Summary

```
User Request
    ↓
/plan-feature-initial
    ↓ (classify + confirm)
/plan-feature
    ↓ (assign techniques per step)
/plan-prompts
    ↓ (embed technique methodology)
/plan-next
    ↓ (execute with phases)
    ├─→ Planning Phase (technique A)
    ├─→ Implementation Phase (technique B)
    └─→ Verification Phase (technique C)
         ↓
    [If fails] → Self-Correction Engine
         ├─→ Memory Bank (lessons)
         ├─→ Retry with same technique
         ├─→ Rotate technique
         └─→ Escalate to user
```

## Next Actions
1. Run `/plan-next 004` to start Step 8b (Prompt Embedding)
2. Continue through remaining 7 steps

## Things to Remember
- All 10 prompt engineering techniques are available in `.claude/commands/`
- Existing plans (001-003) continue to work with legacy prompts
- Python scripts go in `.claude/scripts/`
- Configuration goes in `.claude/technique-config.json`

## Blockers
None currently.

## Learnings
- Hierarchical taxonomy (category → subtype) reduces classification ambiguity
- Phase-based technique composition maps naturally to how work actually flows
- Risk assessment should consider both problem type AND step context
- jsonschema module not available - created custom validation tests instead
- Generic keywords like 'add', 'new', 'feature' need heavy penalty to avoid false positives
- Domain-specific keywords should get extra weight for better accuracy

---

## Step 1 Complete - 2025-12-24

### Summary
Created the technique configuration schema and default mappings that define how problem types map to prompt engineering techniques across planning, implementation, and verification phases.

### Files Created
- `.claude/technique-config.json`: Main configuration with 33 problem subtypes and 10 techniques
- `.claude/schemas/technique-config.schema.json`: JSON schema for validation (Draft-07)
- `.claude/scripts/test_technique_config.py`: Validation test suite (10 tests)

### Verification Results
- [x] AC1: JSON is valid and parseable
- [x] AC2: 33 problem subtypes defined (22+ required)
- [x] AC3: All 10 techniques defined with templates
- [x] AC4: All problem types have all 3 phases defined
- [x] AC5: Schema file exists

### Tests Written
- `test_technique_config.py`: 10 test cases
  - JSON validation
  - Required keys
  - Problem type count (33)
  - Technique count (10)
  - Phase completeness
  - Risk level configs
  - Template file existence
  - Keyword presence
  - Valid risk references
  - Valid technique references
- **Status**: All 10 tests passing

### Key Decisions
- Used array for implementation techniques to support composition (e.g., ["tdd", "self-refine"])
- Keywords chosen to minimize false positives during classification
- Risk levels aligned with retry budgets from plan (low=3, medium=5, high=7, critical=10)
- Added 8 categories (FOUNDATION, DATA, ARCHITECTURE, UI_UX, TESTING, LOGIC, DOCUMENTATION, META)

### Ready for Next Step
Step 2: Problem Classifier Script
Prerequisites met: Yes (technique-config.json exists with all problem types and keywords)

---

## Step 2 Complete - 2025-12-24

### Summary
Implemented ProblemClassifier Python script for automatic problem type detection with weighted keyword matching, context-aware refinement, and confidence calibration.

### Files Created
- `.claude/scripts/__init__.py`: Module init exporting ProblemClassifier, ClassificationResult
- `.claude/scripts/problem_classifier.py`: Main classifier implementation
- `.claude/scripts/test_problem_classifier.py`: Comprehensive unit tests (30 tests)

### Files Modified
- `.claude/technique-config.json`: Added oauth, authentication, auth keywords to api-integration

### Verification Results
- [x] AC1: Classifier correctly identifies debug problems
- [x] AC2: Classifier correctly identifies UI problems
- [x] AC3: Classifier correctly identifies algorithm problems
- [x] AC4: Confidence scores are calibrated (verified via 30 tests)
- [x] AC5: All 30 unit tests pass
- [x] Integration: 5/5 core classifications correct
- [x] Performance: <1ms per classification

### Tests Written
- `test_problem_classifier.py`: 30 test cases across 2 test classes
  - Core classification tests (debug, ui, algorithm, unit-test, refactor, api-integration)
  - Confidence scoring tests
  - Context adjustment tests
  - Fallback behavior tests
  - Keyword matching tests
  - Validation tests
  - Result structure tests
  - Utility method tests
  - Performance tests
  - Integration tests
- **Status**: All 30 tests passing

### Key Decisions
- **Weighted keyword matching**: Longer keywords and multi-word phrases get higher weights
- **Generic keyword penalty**: Keywords like 'add', 'new', 'feature' get 0.3x weight to reduce false positives
- **Specific keyword boost**: Domain keywords like 'screen', 'api', 'refactor' get 1.5x weight
- **Calibration factor**: 0.85 to normalize confidence scores
- **Fallback**: Returns 'new-feature' with 0.3 confidence when no matches

### Learnings
- Generic keywords appearing in many descriptions need heavy penalties
- Domain-specific keywords should get boosted for better accuracy
- Word boundary matching important for short keywords (e.g., "ui", "api")

### Ready for Next Step
Step 3: Technique Selector Script
Prerequisites met: Yes (ProblemClassifier provides classification for technique selection)

---

## Step 3 Complete - 2025-12-29

### Summary
Implemented TechniqueSelector Python script for phase-based technique selection with context-aware adjustment, cost estimation, and technique composition.

### Files Created
- `.claude/scripts/technique_selector.py`: TechniqueSelector class with Phase enum, StepContext, TechniqueSelection, TechniqueMetadata dataclasses
- `.claude/scripts/test_technique_selector.py`: Comprehensive unit tests (36 tests)

### Files Modified
- `.claude/scripts/__init__.py`: Added exports for TechniqueSelector and related classes

### Verification Results
- [x] AC1: Selector returns valid techniques for all problem types
- [x] AC2: Phase-specific selection works correctly
- [x] AC3: Context adjustment works (high complexity -> ToT, failures -> Reflexion)
- [x] AC4: All 36 unit tests pass
- [x] Integration: 4/4 expected selections correct

### Tests Written
- `test_technique_selector.py`: 36 test cases across 2 test classes
  - Basic selection tests (algorithm, ui, debug, system-design)
  - Phase selection tests
  - Context adjustment tests (complexity, failures, early step, risk, files)
  - Unknown problem type tests
  - Cost estimation tests
  - Retry budget tests
  - Prompt template tests
  - Metadata tests
  - Composition tests
  - Utility method tests
  - Integration tests
- **Status**: All 36 tests passing

### Key Decisions
- **Context adjustment rules**: 5 rules for adjusting based on failures, complexity, step position, files affected, and risk level
- **Cost estimation**: Weighted scoring (ToT/GoT/Self-Consistency=3, Reflexion/Self-Refine/TDD/ReAct/Chain-of-Code=2, PS+/Least-to-Most=1)
- **Retry budgets**: Direct from config (low=3, medium=5, high=7, critical=10)
- **Secondary techniques limited to 2**: For composition sanity

### Learnings
- Phase enum must use `.value` for string comparison with config keys
- Secondary techniques need limiting to prevent combinatorial explosion
- Context adjustment can override base selection when conditions are met

### Ready for Next Step
Step 4: Risk Assessor Script
Prerequisites met: Yes (TechniqueSelector provides selection, will integrate with risk assessment)

---

## Step 4 Complete - 2025-12-30

### Summary
Implemented RiskAssessor Python script for step risk assessment with weighted factors, retry configuration, and escalation logic.

### Files Created
- `.claude/scripts/risk_assessor.py`: RiskAssessor class with 10 risk factors, score-to-level mapping, retry configs, and escalation decisions
- `.claude/scripts/test_risk_assessor.py`: Comprehensive unit tests (40 tests)

### Files Modified
- `.claude/scripts/__init__.py`: Added exports for RiskAssessor, RiskLevel, StepInfo, RiskFactor, RetryConfig, RiskAssessment, EscalationDecision

### Verification Results
- [x] AC1: Low-risk documentation steps assessed correctly (level=low, score=0.00)
- [x] AC2: High-risk migration steps assessed correctly (level=high or critical)
- [x] AC3: Retry configs match specification (LOW=3, MEDIUM=5, HIGH=7, CRITICAL=10)
- [x] AC4: All 40 unit tests pass

### Tests Written
- `test_risk_assessor.py`: 40 test cases across 2 test classes
  - Low/medium/high/critical risk assessment tests
  - Retry configuration tests
  - Escalation decision tests (max retries, critical failures)
  - Risk factor application tests
  - Score calculation and clamping tests
  - Context adjustment tests
  - Explanation and mitigation generation tests
  - Utility method tests
  - Integration tests
- **Status**: All 40 tests passing

### Key Decisions
- **10 risk factors** with weights from -0.2 to 0.3:
  - High-weight: data_migration (0.3), breaking_change (0.25), external_api (0.2)
  - Medium-weight: many_file_modifications (0.15), affects_persistence (0.15), complex_dependencies (0.1), high_complexity (0.1)
  - Negative factors: new_files_only (-0.1), documentation_only (-0.2), low_complexity (-0.05)
- **Score-to-level thresholds** aligned with base scores:
  - LOW: < 0.35 (covers low base 0.2 with minor adjustments)
  - MEDIUM: < 0.6 (covers medium base 0.5 with minor adjustments)
  - HIGH: < 0.85 (covers high base 0.8 with minor adjustments)
  - CRITICAL: >= 0.85 (requires multiple high-risk factors)
- **Escalation logic**: Checks max retries, escalation threshold, and critical failure patterns
- **Mitigation suggestions**: Auto-generated based on present risk factors

### Learnings
- Score-to-level thresholds must align with base risk scores from config to avoid unexpected level jumps
- Negative factors (documentation_only, new_files_only) help reduce risk for safe operations
- Escalation patterns should include critical keywords like "corruption", "fatal", "security"

### Ready for Next Step
Step 5: CLI Orchestrator
Prerequisites met: Yes (All core scripts created: classifier, selector, assessor)

---

## Step 5 Complete - 2025-12-30

### Summary
Implemented CLI orchestrator (tangentle-plan) that provides a unified interface for plan management, integrating classifier, selector, and assessor components.

### Files Created
- `.claude/scripts/utils.py`: Shared utilities (find_plan, load_plan_progress, format_box, format_progress_bar, etc.)
- `.claude/scripts/tangentle_plan.py`: Main CLI tool with PlanOrchestrator class
- `.claude/scripts/test_tangentle_plan.py`: Integration tests (36 tests)

### Files Modified
- `.claude/scripts/__init__.py`: Added exports for PlanOrchestrator and utility functions

### Verification Results
- [x] AC1: classify subcommand works - returns type, confidence, techniques
- [x] AC2: status subcommand works - shows plan progress with progress bar
- [x] AC3: list subcommand works - lists all plans with status indicators
- [x] AC4: Help text is useful - shows all subcommands and examples
- [x] AC5: Exit codes correct - 0 for success, 1 for errors

### Tests Written
- `test_tangentle_plan.py`: 36 test cases across 4 test classes
  - TestPlanOrchestrator (15 tests): classify, techniques, risk assessment
  - TestCliCommands (10 tests): classify, status, list, techniques, risk
  - TestUtils (9 tests): find_plan, load_progress, format functions
  - TestIntegration (2 tests): full workflow, all problem types
- **Status**: All 36 tests passing

### CLI Commands Implemented
| Command | Description |
|---------|-------------|
| `classify <desc>` | Classify a problem description |
| `techniques <type>` | Show techniques for a problem type |
| `risk <type>` | Assess risk for a step |
| `status <plan_id>` | Show plan status with progress bar |
| `list` | List all plans with status |

### Key Decisions
- **argparse subcommands**: Clean separation of concerns per command
- **PlanOrchestrator class**: Integrates all three components (classifier, selector, assessor)
- **Formatted output**: Progress bars, risk indicators, status emojis
- **Exit codes**: 0 for success, 1 for errors (scriptable)
- **Placeholder commands**: create, prompts, next, verify, rollback (not yet implemented)

### Learnings
- CLI needs to handle working directory changes when run from scripts dir
- StringIO capture for testing CLI output works well
- Integration tests catch issues that unit tests miss

### Ready for Next Step
Step 6: Update plan-feature-initial
Prerequisites met: Yes (CLI provides foundation for command integration)

---

## Step 6 Complete - 2025-12-31

### Summary
Updated `/plan-feature-initial` command to automatically detect problem types using the classifier, display suggested techniques, and include technique metadata in the output template.

### Files Modified
- `.claude/commands/plan-feature-initial.md`: Added classification step, technique display, confirmation question, updated output template

### Changes Made
1. **Added Step 1.5: Classify Problem Type** - Calls `tangentle_plan.py classify` before analysis
2. **Added classification display format** - Shows type, category, confidence, and suggested techniques
3. **Added manual fallback** - Keyword-based classification when Python unavailable
4. **Added Problem Type Confirmation** - Question 0 in blocking questions section
5. **Updated output template** - Added Problem Classification and Technique Selection sections

### Verification Results
- [x] AC1: Classification step added (`grep "Classify Problem Type"` → found)
- [x] AC2: Technique section in output template (`grep "Technique Selection"` → found)
- [x] AC3: Confirmation question added (`grep "classification correct"` → found)
- [x] AC4: Manual fallback exists (`grep "manually classify"` → found)
- [x] AC5: Original functionality preserved (Tree of Thought, questions, template all intact)

### Integration Test
```bash
$ python3 .claude/scripts/tangentle_plan.py classify "Add OAuth authentication"
# Returns: api-integration (85% confidence)
```

### Key Decisions
- Classification step numbered as 1.5 to fit between existing steps
- Confirmation question numbered as Question 0 to appear first
- Manual fallback uses simple keyword matching (debug, ui, refactor, etc.)
- CLI integration via `tangentle_plan.py classify` command

### Learnings
- Command files are markdown-based instruction templates
- Adding numbered sub-steps (1.5) preserves existing structure
- Fallback mechanism essential for when Python scripts unavailable

### Ready for Next Step
Step 8a: Technique Template Extraction
Prerequisites met: Yes (plan-feature now includes technique metadata in plans)

---

## Step 7 Complete - 2025-12-31

### Summary
Updated `/plan-feature` command to embed technique selection in plans, add technique metadata to progress.json, and generate technique-aware step files.

### Files Modified
- `.claude/commands/plan-feature.md`: Added Step 6.5 (Assign Techniques), updated plan.md template with technique matrix, updated step file template with technique sections, extended progress.json schema

### Changes Made
1. **Step 6.5: Assign Techniques to Steps** - New section that:
   - Classifies each step's problem type (may differ from overall plan type)
   - Selects techniques per phase using CLI or fallback table
   - Assesses risk per step with retry configuration
   - Documents technique rationale

2. **plan.md Template Updates**:
   - Added Technique Matrix section with columns: Step, Problem Type, Planning, Implementation, Verification, Risk
   - Updated Implementation Steps table with Type and Risk columns

3. **Step File Template Updates**:
   - Added Problem Type section
   - Added Technique Selection section (per phase with rationale)
   - Added Risk Level section
   - Added Retry Configuration section

4. **progress.json Schema Updates**:
   - Added top-level: `problemType`, `problemCategory`, `techniqueProfile`
   - Added per-step: `problemType`, `techniques`, `techniqueRationale`, `riskLevel`, `riskScore`, `retryConfig`, `techniquesUsed`

5. **Fallback Mechanism**:
   - Keyword-based classification when Python unavailable
   - Technique reference table for manual lookup

### Verification Results
- [x] AC1: Step 6.5 added (`grep "Assign Techniques to Steps"` → found)
- [x] AC2: Technique Matrix in plan.md template (`grep "Technique Matrix"` → found)
- [x] AC3: techniqueProfile in progress.json schema (`grep "techniqueProfile"` → found)
- [x] AC4: Fallback works without Python (`grep "If Python unavailable"` → found)
- [x] AC5: Step file has Technique Selection section (found)
- [x] AC6: Step file has Risk Level section (found)
- [x] AC7: Step file has Retry Configuration section (found)

### Key Decisions
- Step 6.5 placed after ADR creation but before step file creation (logical flow)
- Fallback technique table covers 9 most common problem types
- Risk assessment includes 5 key factors (migration, API, breaking, persistence, complexity)
- Retry config defaults: Low=3, Medium=5, High=7, Critical=10

### Learnings
- Step file template needed multiple new sections (problem type, techniques, risk, retry config)
- progress.json schema now matches the structure used by Plan 004 itself
- Fallback table essential for environments without Python scripts

---

## Step 8a Complete - 2025-12-31

### Summary
Added section markers to all 10 technique template files and created a template parser that extracts structured TechniqueTemplate objects for programmatic composition.

### Files Created
- `.claude/scripts/template_parser.py`: Parser with TechniqueTemplate dataclass, parse_technique_template(), load_all_templates()
- `.claude/scripts/test_template_parser.py`: 22 unit tests for parser functionality

### Files Modified
- All 10 technique files in `.claude/commands/`: Added section markers (PLANNING, IMPLEMENTATION, VERIFICATION, ERROR_RECOVERY)
- `.claude/scripts/__init__.py`: Added exports for template parser functions

### Section Marker Format
```markdown
<!-- SECTION:PLANNING -->
## Planning Phase
...
<!-- /SECTION:PLANNING -->

<!-- SECTION:IMPLEMENTATION -->
## Implementation Phase
...
<!-- /SECTION:IMPLEMENTATION -->

<!-- SECTION:VERIFICATION -->
## Verification Phase
...
<!-- /SECTION:VERIFICATION -->

<!-- SECTION:ERROR_RECOVERY -->
## Error Recovery
...
<!-- /SECTION:ERROR_RECOVERY -->
```

### Verification Results
- [x] AC1: All 10 technique files have section markers (`grep -l "SECTION:IMPLEMENTATION" .claude/commands/*.md | wc -l` = 10)
- [x] AC2: Parser extracts all sections correctly (TDD template: 2332 chars in implementation)
- [x] AC3: Missing sections return empty string
- [x] AC4: All templates load successfully (10 templates loaded, all 3/3 sections)
- [x] AC5: Unit tests pass (22 tests, 0 failures)

### Tests Written
- `test_template_parser.py`: 22 test cases
  - TestTechniqueTemplate (2 tests): defaults, full creation
  - TestParseMarkedTemplate (3 tests): sections, placeholders, description
  - TestParseLegacyTemplate (1 test): heuristic parsing
  - TestMissingSections (1 test): empty string return
  - TestLoadAllTemplates (3 tests): load all, implementation section, parse success
  - TestHelperFunctions (8 tests): title, description, placeholders, section getters
  - TestActualTemplates (3 tests): TDD, Reflexion, ToT parsing
  - TestFileNotFound (1 test): error handling
- **Status**: All 22 tests passing

### Key Decisions
- HTML comment markers for section delimiters (invisible in rendered markdown)
- TechniqueTemplate with 8 fields: id, name, description, 4 section fields, placeholders
- Heuristic parsing per-technique (each has unique header patterns)
- Graceful fallback: missing sections return empty string, parser continues

### Learnings
- Technique-specific section patterns needed for heuristic parsing
- pytest not available - used unittest module instead
- Parser needs working directory handling when run from scripts dir

### Ready for Next Step
Step 8b: Prompt Embedding
Prerequisites met: Yes (TechniqueTemplate parser can load and extract sections from all technique files)
