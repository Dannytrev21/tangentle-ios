# Claude Scripts Module
# Python utilities for the intelligent planning system

from .problem_classifier import ProblemClassifier, ClassificationResult
from .technique_selector import (
    TechniqueSelector,
    Phase,
    StepContext,
    TechniqueSelection,
    TechniqueMetadata
)
from .risk_assessor import (
    RiskAssessor,
    RiskLevel,
    StepInfo,
    RiskFactor,
    RetryConfig,
    RiskAssessment,
    EscalationDecision
)
from .tangentle_plan import PlanOrchestrator
from .utils import (
    find_plan,
    load_plan_progress,
    save_plan_progress,
    list_all_plans,
    format_box,
    format_progress_bar,
    format_risk_level,
    format_status
)
from .template_parser import (
    TechniqueTemplate,
    parse_technique_template,
    load_all_templates,
    get_template_section,
    template_has_section
)
from .prompt_composer import (
    compose_prompt,
    compose_from_step_file,
    substitute_placeholders,
    truncate_with_summary,
    validate_techniques,
    get_technique_names,
    StepInfo as PromptStepInfo,
    PlanInfo
)
from .memory_bank import (
    MemoryBank,
    MemoryBankEntry,
    create_entry_from_failure
)
from .self_correction import (
    SelfCorrectionEngine,
    FailureInfo,
    RetryDecision,
    TECHNIQUE_ALTERNATIVES,
    FAILURE_PATTERN_TECHNIQUES
)

__all__ = [
    # Problem Classifier
    'ProblemClassifier',
    'ClassificationResult',
    # Technique Selector
    'TechniqueSelector',
    'Phase',
    'StepContext',
    'TechniqueSelection',
    'TechniqueMetadata',
    # Risk Assessor
    'RiskAssessor',
    'RiskLevel',
    'StepInfo',
    'RiskFactor',
    'RetryConfig',
    'RiskAssessment',
    'EscalationDecision',
    # Plan Orchestrator
    'PlanOrchestrator',
    # Utilities
    'find_plan',
    'load_plan_progress',
    'save_plan_progress',
    'list_all_plans',
    'format_box',
    'format_progress_bar',
    'format_risk_level',
    'format_status',
    # Template Parser
    'TechniqueTemplate',
    'parse_technique_template',
    'load_all_templates',
    'get_template_section',
    'template_has_section',
    # Prompt Composer
    'compose_prompt',
    'compose_from_step_file',
    'substitute_placeholders',
    'truncate_with_summary',
    'validate_techniques',
    'get_technique_names',
    'PromptStepInfo',
    'PlanInfo',
    # Memory Bank
    'MemoryBank',
    'MemoryBankEntry',
    'create_entry_from_failure',
    # Self Correction
    'SelfCorrectionEngine',
    'FailureInfo',
    'RetryDecision',
    'TECHNIQUE_ALTERNATIVES',
    'FAILURE_PATTERN_TECHNIQUES',
]
