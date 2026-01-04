# ADR: Windsurf Cascade Plan Command System Migration

## Status
Proposed

## Context
The Claude Code planning system provides sophisticated AI-assisted development workflows with:
- Intelligent problem classification (33 problem types across 8 categories)
- Automatic technique selection (10 prompt engineering techniques)
- Phase-based execution (Planning → Implementation → Verification)
- Self-correction with memory bank and technique rotation
- Progress persistence and context preservation

This system needs to be migrated to Windsurf IDE (Cascade) to enable the same quality-focused development workflow in a different IDE environment. Windsurf has different capabilities:
- Workflows are markdown files with 12,000 character limits
- Rules provide persistent instructions
- Memories offer auto-generated context persistence
- Knowledge files store reference documentation
- Workflow nesting allows composition

## Tree of Thought Analysis

### Decision 1: Hybrid Python + Workflow Architecture

**Problem**: Windsurf workflows are markdown-based and cannot contain complex algorithmic logic, but the planning system requires sophisticated classification, selection, and self-correction algorithms.

**Options Considered**:

| Option | Description | Effort | Maintainability | Quality |
|--------|-------------|--------|-----------------|---------|
| A | All logic in AI instructions | Low | Poor | Medium |
| B | All logic in Python, minimal workflows | Medium | Good | High |
| C | Hybrid: Python for algorithms, workflows for orchestration | High | Best | Highest |

**Analysis**:
- **Option A** risks inconsistent behavior since AI reasoning varies
- **Option B** keeps proven logic but underutilizes Windsurf features
- **Option C** combines Python's reliability with Windsurf's native capabilities

**Decision**: **Option C (Hybrid)**

The system will use:
- Python scripts for deterministic logic (classification, selection, risk assessment)
- Workflows for orchestration and user interaction
- Windsurf Memories for cross-plan learnings
- File-based storage for plan-specific context

**Rationale**: This preserves the battle-tested classification and selection algorithms while adapting to Windsurf's workflow-first model. Workflows invoke Python scripts via shell commands, and Python handles the complex logic.

---

### Decision 2: Workflow Decomposition Under 12K Limit

**Problem**: Claude Code commands are 300-600 lines each. Windsurf workflows have a 12,000 character limit.

**Options Considered**:

| Option | Description | Files | Reuse | Complexity |
|--------|-------------|-------|-------|------------|
| A | Monolithic workflows | 8 | None | Low |
| B | Main + helper workflows | 12-15 | High | Medium |
| C | Templates + stub workflows | 20+ | Maximum | High |

**Analysis**:
- **Option A** will likely exceed limits for complex workflows like `/plan-next`
- **Option B** provides natural decomposition points
- **Option C** adds unnecessary indirection

**Decision**: **Option B (Main + Helper Workflows)**

Structure:
```
.windsurf/workflows/
├── plan-feature-initial.md    # Main: requirements analysis
├── plan-feature.md            # Main: plan creation
├── plan-prompts.md            # Main: prompt generation
├── plan-next.md               # Main: step execution
├── plan-status.md             # Main: progress display
├── plan-verify.md             # Main: verification
├── plan-rollback.md           # Main: rollback
├── plan-feature-review.md     # Main: plan review
├── _internal-verify.md        # Helper: shared verification
├── _internal-commit.md        # Helper: commit staging
└── _internal-init.md          # Helper: initialization
```

**Rationale**: Helper workflows (prefixed with `_`) contain shared logic. Main workflows handle user interaction and orchestration. This keeps each file under the limit while maximizing reuse.

---

### Decision 3: Technique Embedding Strategy

**Problem**: Technique instructions (TDD, Reflexion, etc.) are 300-7000 lines each. Step prompts need these instructions for proper execution.

**Options Considered**:

| Option | Description | Prompt Size | Reliability | User Request |
|--------|-------------|-------------|-------------|--------------|
| A | Full inline | Very large | Highest | Requested |
| B | Reference by path | Small | Medium | N/A |
| C | Condensed inline | Medium | Good | N/A |

**Decision**: **Option A (Full inline)** per user preference

Step prompts will contain the complete technique instructions. Prompt files will be larger (potentially 1000-2000 lines) but fully self-contained.

**Mitigations**:
- Python script generates prompts programmatically
- Technique content stored in `.windsurf/knowledge/techniques/` as source
- Prompt composer reads technique files and embeds in generated prompts

---

### Decision 4: Per-Step File Tracking Schema

**Problem**: Need to track which files were touched during each step for precise commit staging and rollback.

**Options Considered**:

| Option | Schema | Git Operations | Rollback Support |
|--------|--------|----------------|------------------|
| A | `filesCreated[]`, `filesModified[]` | Add, Reset | Partial |
| B | All 4 operations | Add, Reset, Rm, Mv | Full |
| C | Single list with metadata | Complex parsing | Full |

**Decision**: **Option B (All 4 operations)**

```json
{
  "steps": [{
    "files": {
      "created": ["path/to/new.py"],
      "modified": ["path/to/existing.py"],
      "deleted": ["path/to/removed.py"],
      "renamed": [{"from": "old.py", "to": "new.py"}]
    }
  }]
}
```

**Rationale**: Full operation tracking enables:
- Precise `git add` for commits (created + modified)
- Safe `git checkout` for rollback (modified)
- Safe `rm` for rollback (created)
- Restoration for rollback (deleted, renamed)

---

### Decision 5: Verification Command Discovery

**Problem**: System must work across any repository (JavaScript, Python, Rust, Go, etc.) without hardcoded build/test commands.

**Options Considered**:

| Option | Coverage | User Friction | Maintenance |
|--------|----------|---------------|-------------|
| A | Deep (10+ file types) | Low | High |
| B | Common (4-5 file types) | Medium | Low |
| C | Always prompt | High | None |

**Decision**: **Option A (Deep inspection)** per user preference

Detection order:
1. Check `.windsurf/knowledge/repo-commands.md` (cached)
2. If not cached, scan for:
   - `package.json` → npm/yarn/pnpm scripts
   - `Makefile` → make targets
   - `.github/workflows/*.yml` → CI commands
   - `setup.py` / `pyproject.toml` → pytest/tox
   - `Cargo.toml` → cargo test/build
   - `go.mod` → go test/build
   - `build.gradle` / `pom.xml` → gradle/maven
   - `CMakeLists.txt` → cmake/ctest
   - `README.md` → documented commands
3. If low confidence, prompt user
4. Cache in `.windsurf/knowledge/repo-commands.md`

---

### Decision 6: Memory Bank Architecture

**Problem**: Need to preserve lessons learned across sessions for self-correction.

**Options Considered**:

| Option | Plan-Specific | Cross-Plan | Native Integration |
|--------|---------------|------------|-------------------|
| A | File-based | None | No |
| B | Windsurf Memories | Native | Yes, but limited control |
| C | Hybrid | Both | Partial |

**Decision**: **Option C (Hybrid)** per user preference

Architecture:
```
Plan-specific:
  .windsurf/plans/{NNN}/memory-bank.json
  - Max 10 entries (FIFO)
  - Contains: failure patterns, successful fixes, technique effectiveness

Cross-plan:
  Windsurf native Memories
  - Created via workflow instruction: "create a memory of {insight}"
  - Contains: architectural patterns, common mistakes, project conventions
```

**Rationale**: File-based storage ensures plan-specific context survives across Cascade sessions. Native Memories enable Cascade to automatically recall cross-plan learnings.

---

### Decision 7: Review System with Agentic Reasoning

**Problem**: `/plan-feature-review` needs to deeply analyze plans for quality issues.

**Options Considered**:

| Option | Analysis Depth | Reasoning Quality | Token Cost |
|--------|----------------|-------------------|------------|
| A | Checklist | Low | Low |
| B | Tree of Thought | High | Medium |
| C | Full agentic (ToT + GoT) | Highest | High |

**Decision**: **Option C (Full Agentic Reasoning)** per user preference

Review dimensions:
1. **Completeness** - Are all requirements covered?
2. **Sequencing** - Are dependencies correctly ordered?
3. **Granularity** - Are steps appropriately sized (30-90 min)?
4. **Technical Quality** - Are patterns/conventions followed?
5. **Risk Assessment** - Are high-risk steps identified?
6. **Technique Appropriateness** - Are techniques well-matched to problems?

Process:
1. Tree of Thought explores each dimension independently
2. Graph of Thought merges findings, identifies conflicts
3. Score each dimension (1-10)
4. Generate recommendations with priority ordering
5. Write `reviews/review-{date}.md`

---

## Decision Summary

| Decision | Selected | Rationale |
|----------|----------|-----------|
| Architecture | Hybrid Python + Workflows | Best of both worlds |
| Decomposition | Main + Helper workflows | Under 12K limit with reuse |
| Technique embedding | Full inline in prompts | User preference, self-contained |
| File tracking | All 4 operations | Full rollback/commit support |
| Command discovery | Deep inspection | Repo-agnostic across stacks |
| Memory bank | Hybrid file + Memories | Plan-specific + cross-plan |
| Review system | Full agentic ToT + GoT | Highest quality analysis |

## Consequences

### Positive
- Preserves all Claude Code capabilities in Windsurf
- Python scripts provide deterministic, testable logic
- Workflows stay under character limits via decomposition
- Full file tracking enables precise git operations
- Memory bank learning improves over time
- Deep inspection works across any tech stack

### Negative
- More files to maintain than Claude Code (~30 vs ~24)
- Inline technique embedding creates large prompt files
- Hybrid memory approach adds complexity
- Deep inspection requires maintaining file type knowledge

### Mitigations
- Clear directory structure with naming conventions
- Prompt generation is automated via Python
- Memory bank has clear separation of concerns
- File type detection is data-driven, easily extended

## Related Decisions
- Plan 004 established technique selection algorithm (reused)
- Python scripts use standard library only (portable)
- All artifacts under `.windsurf/` never committed
