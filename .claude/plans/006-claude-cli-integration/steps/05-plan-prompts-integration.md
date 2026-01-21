# Step 5: Plan-Prompts Integration

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to command modification
- **Implementation**: self-refine - Iteratively improve integration
- **Verification**: tdd - Verify generated prompts include thinking keywords

## Risk Level
**medium** - Modifying command that generates all plan prompts

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** how thinking keywords are injected into generated prompts.

## Context
This step modifies the plan-prompts command to embed thinking keywords based on step risk level. The command generates prompts for each plan step, and now must include the appropriate reasoning depth instruction.

## Goal
Update plan-prompts.md to replace {THINKING_KEYWORD} placeholder with appropriate keyword based on step's risk level from progress.json.

## Prerequisites
- Step 3 completed (thinking keywords utility exists)
- Step 4 completed (template has {THINKING_KEYWORD} placeholder)

## High-Level Steps
1. Read current plan-prompts.md command
2. Add instruction to read step risk level from progress.json
3. Add logic to select thinking keyword based on risk
4. Add placeholder replacement in prompt generation
5. Verify generated prompts have correct keywords

## Detailed Requirements

### Risk Level Reading
Add to Step 4 (Generate Prompt for Each Step):
```markdown
#### Determine Thinking Keyword
For each step, read the risk level from progress.json:
```bash
# Read step risk level
risk_level=$(cat {plan-dir}/progress.json | jq -r ".steps[$i].riskLevel")
```

Map to thinking keyword:
| Risk Level | Thinking Keyword |
|------------|------------------|
| low | Think about |
| medium | Think hard about |
| high | Ultrathink about |
| critical | Ultrathink about |

If risk level is missing, default to "Think hard about".
```

### Placeholder Replacement
Add to prompt generation logic:
```markdown
#### Replace Thinking Keyword
In the generated prompt, replace `{THINKING_KEYWORD}` with the mapped keyword:

```markdown
## Reasoning Depth
{MAPPED_KEYWORD} the following aspects before implementation:
```

Example for a medium-risk step:
```markdown
## Reasoning Depth
Think hard about the following aspects before implementation:
```
```

### Update Prompt Template Section
Modify the template to show the replacement:
```markdown
The prompt should include a Reasoning Depth section:

```markdown
## Reasoning Depth
{risk_level → keyword} the following aspects before implementation:
1. What are the potential failure modes?
2. What existing patterns should be followed?
3. What tests will verify success?
4. What could go wrong and how to prevent it?
```
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-prompts.md`: Add risk reading and keyword replacement logic

## Patterns to Follow
Reference: Current progress.json reading pattern in plan-prompts.md
Reference: Thinking keyword mapping from Step 3

## Acceptance Criteria
- [ ] Command reads risk level from progress.json for each step
- [ ] Correct thinking keyword is selected based on risk
- [ ] Generated prompts contain actual keyword (not placeholder)
- [ ] Low-risk steps get "Think about"
- [ ] Medium-risk steps get "Think hard about"
- [ ] High/critical-risk steps get "Ultrathink about"
- [ ] Missing risk level defaults to "Think hard about"

## Testing Requirements
**Manual Verification**:
- Generate prompts for a test plan with mixed risk levels
- Verify each prompt has correct thinking keyword
- Check that no {THINKING_KEYWORD} placeholder remains

### Verification Test Cases
- Low-risk step prompt contains "Think about"
- Medium-risk step prompt contains "Think hard about"
- High-risk step prompt contains "Ultrathink about"
- No placeholder text in any generated prompt

## Verification Commands
```bash
# Generate prompts for plan 006 (this plan has mixed risk levels)
# Then verify keywords in generated prompts

# Check for any remaining placeholders
grep -r "THINKING_KEYWORD" .claude/plans/006-claude-cli-integration/prompts/

# Check for correct keywords
grep -l "Think about" .claude/plans/006-claude-cli-integration/prompts/*.md
grep -l "Think hard about" .claude/plans/006-claude-cli-integration/prompts/*.md
grep -l "Ultrathink about" .claude/plans/006-claude-cli-integration/prompts/*.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Check risk level reading logic
2. Verify keyword mapping is correct
3. Check placeholder replacement syntax
4. Re-generate prompts and verify

## Do NOT
- Hardcode keywords without reading risk level
- Leave placeholder unreplaced in any prompt
- Change risk levels in progress.json (read-only)
- Modify the thinking keyword mapping (defined in Step 3)
