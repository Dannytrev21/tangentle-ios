#!/usr/bin/env python3
"""
Tests for technique-config.json validation.

These tests verify the configuration file structure and content
without requiring external dependencies like jsonschema.

Run: python3 .claude/scripts/test_technique_config.py
"""

import json
import os
import sys
from pathlib import Path


def get_config_path() -> Path:
    """Get the path to technique-config.json."""
    # Find the config relative to this script or from current directory
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / "technique-config.json"
    if config_path.exists():
        return config_path

    # Try from current working directory
    cwd_path = Path(".claude/technique-config.json")
    if cwd_path.exists():
        return cwd_path

    raise FileNotFoundError("Could not find technique-config.json")


def load_config() -> dict:
    """Load and parse the technique configuration."""
    config_path = get_config_path()
    with open(config_path) as f:
        return json.load(f)


def test_json_valid():
    """Test that JSON is valid and parseable."""
    try:
        config = load_config()
        assert isinstance(config, dict), "Config should be a dictionary"
        print("  [PASS] JSON is valid and parseable")
        return True
    except json.JSONDecodeError as e:
        print(f"  [FAIL] JSON parse error: {e}")
        return False


def test_required_top_level_keys():
    """Test that all required top-level keys exist."""
    config = load_config()
    required_keys = ["version", "problemTypes", "techniques", "riskLevels", "defaults"]
    missing = [k for k in required_keys if k not in config]

    if missing:
        print(f"  [FAIL] Missing required keys: {missing}")
        return False

    print("  [PASS] All required top-level keys present")
    return True


def test_problem_type_count():
    """Test that we have at least 22 problem subtypes."""
    config = load_config()
    total_subtypes = sum(
        len(cat_data.get("subtypes", {}))
        for cat_data in config["problemTypes"].values()
    )

    if total_subtypes < 22:
        print(f"  [FAIL] Only {total_subtypes} problem subtypes (need 22+)")
        return False

    print(f"  [PASS] {total_subtypes} problem subtypes defined (22+ required)")
    return True


def test_technique_count():
    """Test that we have all 10 techniques."""
    config = load_config()
    technique_count = len(config.get("techniques", {}))

    expected_techniques = [
        "tot", "got", "reflexion", "self-consistency", "self-refine",
        "tdd", "react", "ps-plus", "chain-of-code", "least-to-most"
    ]

    missing = [t for t in expected_techniques if t not in config.get("techniques", {})]

    if missing:
        print(f"  [FAIL] Missing techniques: {missing}")
        return False

    if technique_count != 10:
        print(f"  [FAIL] Expected 10 techniques, got {technique_count}")
        return False

    print(f"  [PASS] All 10 techniques defined")
    return True


def test_all_phases_defined():
    """Test that every problem subtype has all 3 phases defined."""
    config = load_config()
    phases = ["planning", "implementation", "verification"]
    errors = []

    for category, cat_data in config["problemTypes"].items():
        for subtype, sub_data in cat_data.get("subtypes", {}).items():
            techniques = sub_data.get("techniques", {})
            for phase in phases:
                if phase not in techniques:
                    errors.append(f"{category}/{subtype} missing {phase}")

    if errors:
        print(f"  [FAIL] Missing phases:")
        for err in errors[:5]:  # Show first 5
            print(f"    - {err}")
        if len(errors) > 5:
            print(f"    ... and {len(errors) - 5} more")
        return False

    print("  [PASS] All problem types have all 3 phases defined")
    return True


def test_risk_levels_complete():
    """Test that all risk levels have retry configs."""
    config = load_config()
    required_levels = ["low", "medium", "high", "critical"]
    errors = []

    for level in required_levels:
        if level not in config.get("riskLevels", {}):
            errors.append(f"Missing risk level: {level}")
            continue

        level_config = config["riskLevels"][level]
        retry_config = level_config.get("retryConfig", {})

        for field in ["maxSameTechnique", "maxAlternative", "maxTotal"]:
            if field not in retry_config:
                errors.append(f"{level} missing retryConfig.{field}")

    if errors:
        print(f"  [FAIL] Risk level issues:")
        for err in errors:
            print(f"    - {err}")
        return False

    print("  [PASS] All risk levels have complete retry configs")
    return True


def test_technique_templates_exist():
    """Test that technique template files exist."""
    config = load_config()
    script_dir = Path(__file__).parent.parent.parent  # .claude/scripts -> root
    errors = []

    for tech_id, tech_data in config.get("techniques", {}).items():
        template_path = tech_data.get("promptTemplate", "")
        full_path = script_dir / template_path

        if not full_path.exists():
            errors.append(f"{tech_id}: {template_path} not found")

    if errors:
        print(f"  [FAIL] Missing template files:")
        for err in errors:
            print(f"    - {err}")
        return False

    print("  [PASS] All technique template files exist")
    return True


def test_keywords_not_empty():
    """Test that all problem subtypes have at least one keyword."""
    config = load_config()
    errors = []

    for category, cat_data in config["problemTypes"].items():
        for subtype, sub_data in cat_data.get("subtypes", {}).items():
            keywords = sub_data.get("keywords", [])
            if not keywords:
                errors.append(f"{category}/{subtype} has no keywords")

    if errors:
        print(f"  [FAIL] Problem types missing keywords:")
        for err in errors:
            print(f"    - {err}")
        return False

    print("  [PASS] All problem types have keywords")
    return True


def test_valid_risk_level_references():
    """Test that all problem subtypes reference valid risk levels."""
    config = load_config()
    valid_levels = set(config.get("riskLevels", {}).keys())
    errors = []

    for category, cat_data in config["problemTypes"].items():
        for subtype, sub_data in cat_data.get("subtypes", {}).items():
            level = sub_data.get("riskLevel", "")
            if level not in valid_levels:
                errors.append(f"{category}/{subtype} has invalid riskLevel: {level}")

    if errors:
        print(f"  [FAIL] Invalid risk level references:")
        for err in errors:
            print(f"    - {err}")
        return False

    print("  [PASS] All risk level references are valid")
    return True


def test_valid_technique_references():
    """Test that all technique references point to defined techniques."""
    config = load_config()
    valid_techniques = set(config.get("techniques", {}).keys())
    errors = []

    for category, cat_data in config["problemTypes"].items():
        for subtype, sub_data in cat_data.get("subtypes", {}).items():
            techniques = sub_data.get("techniques", {})

            # Check planning
            if techniques.get("planning") not in valid_techniques:
                errors.append(f"{category}/{subtype}.planning: {techniques.get('planning')}")

            # Check implementation (can be string or list)
            impl = techniques.get("implementation", [])
            if isinstance(impl, str):
                impl = [impl]
            for t in impl:
                if t not in valid_techniques:
                    errors.append(f"{category}/{subtype}.implementation: {t}")

            # Check verification
            if techniques.get("verification") not in valid_techniques:
                errors.append(f"{category}/{subtype}.verification: {techniques.get('verification')}")

    if errors:
        print(f"  [FAIL] Invalid technique references:")
        for err in errors[:10]:
            print(f"    - {err}")
        if len(errors) > 10:
            print(f"    ... and {len(errors) - 10} more")
        return False

    print("  [PASS] All technique references are valid")
    return True


def run_all_tests() -> bool:
    """Run all tests and return overall success."""
    print("\n" + "=" * 60)
    print("  TECHNIQUE CONFIG VALIDATION TESTS")
    print("=" * 60 + "\n")

    tests = [
        ("JSON Valid", test_json_valid),
        ("Required Keys", test_required_top_level_keys),
        ("Problem Type Count", test_problem_type_count),
        ("Technique Count", test_technique_count),
        ("All Phases Defined", test_all_phases_defined),
        ("Risk Levels Complete", test_risk_levels_complete),
        ("Template Files Exist", test_technique_templates_exist),
        ("Keywords Present", test_keywords_not_empty),
        ("Valid Risk References", test_valid_risk_level_references),
        ("Valid Technique References", test_valid_technique_references),
    ]

    results = []
    for name, test_fn in tests:
        print(f"Test: {name}")
        try:
            result = test_fn()
            results.append((name, result))
        except Exception as e:
            print(f"  [ERROR] {e}")
            results.append((name, False))
        print()

    # Summary
    passed = sum(1 for _, r in results if r)
    total = len(results)

    print("=" * 60)
    print(f"  SUMMARY: {passed}/{total} tests passed")
    print("=" * 60)

    if passed == total:
        print("\n  All tests passed!\n")
        return True
    else:
        print("\n  Some tests failed. Please fix the issues above.\n")
        return False


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
