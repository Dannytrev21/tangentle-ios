# Step 12: Integration Testing

## Problem Type
`integration-test`

## Technique Selection
- **Planning**: ps-plus - Clear test scenarios
- **Implementation**: tdd - Tests define expected behavior
- **Verification**: reflexion - Learn from test failures

## Risk Level
**medium** - Validates entire feedback system

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This final step creates comprehensive integration tests that verify the entire feedback system works end-to-end. These tests simulate real usage scenarios and ensure all components integrate correctly.

## Goal
Create integration tests that verify:
1. Full feedback loop (record → query → adapt)
2. Classification learning flow
3. Plan-next integration
4. Multi-agent coordination
5. System recovery from failures

## Prerequisites
- All previous steps (1-11) completed

## High-Level Steps
1. Design integration test scenarios
2. Create test fixtures
3. Implement end-to-end tests
4. Add performance benchmarks
5. Document test coverage

## Detailed Requirements

### Test Scenarios

#### Scenario 1: Feedback Loop End-to-End
```python
def test_feedback_loop_full_cycle():
    """
    Test the complete feedback loop:
    1. Record technique outcomes
    2. Reach threshold
    3. Verify selection changes
    """
    store = FeedbackStore(base_path=temp_dir)
    tracker = EffectivenessTracker(store)
    selector = TechniqueSelector(effectiveness_tracker=tracker)

    # Initially: use config default
    result1 = selector.select_techniques('debug', Phase.IMPLEMENTATION)
    assert result1.primary == 'reflexion'  # Config default
    assert result1.confidence == 0.5

    # Record 10 TDD successes for debug
    for i in range(10):
        tracker.record_outcome('debug', 'tdd', True, 1)

    # Record 10 Reflexion failures for debug
    for i in range(10):
        tracker.record_outcome('debug', 'reflexion', False, 3)

    # Now: should recommend TDD based on effectiveness
    result2 = selector.select_techniques('debug', Phase.IMPLEMENTATION)
    assert result2.primary == 'tdd'  # Learned preference
    assert result2.confidence > 0.7
```

#### Scenario 2: Classification Learning
```python
def test_classification_learning_from_corrections():
    """
    Test that classification improves from user corrections:
    1. Add classification
    2. Record correction
    3. Similar description should use learned type
    """
    store = FeedbackStore(base_path=temp_dir)
    history = ClassificationHistory(store)

    # Initial classification
    entry = history.add_classification(
        description="Add unit tests for auth module",
        classified_as="unit-test",
        confidence=0.9
    )

    # User correction
    history.record_correction(entry.id, "integration-test")

    # Similar description should learn
    result = history.get_learned_classification(
        "Add unit tests for authentication"
    )
    assert result is not None
    assert result[0] == "integration-test"
    assert result[1] > 0.5  # Reasonable confidence
```

#### Scenario 3: Implementation Attempt Tracking
```python
def test_implementation_tracking_avoids_repetition():
    """
    Test that tracker identifies methods to avoid:
    1. Record failed attempt with TDD
    2. Record failed attempt with Reflexion
    3. Suggest next should exclude both
    """
    store = FeedbackStore(base_path=temp_dir)
    tracker = ImplementationTracker(store)

    # Failed TDD attempt
    tracker.start_attempt('007', 3, 'debug', 'tdd', 'Write failing test first')
    tracker.end_attempt('007', 3, False, 'Test framework issue')

    # Failed Reflexion attempt
    tracker.start_attempt('007', 3, 'debug', 'reflexion', 'Analyze patterns')
    tracker.end_attempt('007', 3, False, 'Pattern not found')

    # Check methods to avoid
    avoid = tracker.get_methods_to_avoid('007', 3)
    assert ('tdd', 'Write failing test first') in avoid
    assert ('reflexion', 'Analyze patterns') in avoid

    # Suggestion should exclude failed techniques
    available = ['tdd', 'reflexion', 'self-refine', 'ps-plus']
    suggestion = tracker.suggest_next_technique('007', 3, available)
    assert suggestion in ['self-refine', 'ps-plus']
```

#### Scenario 4: Metrics Aggregation
```python
def test_metrics_aggregate_correctly():
    """
    Test that plan metrics are calculated correctly:
    1. Simulate plan completions
    2. Verify aggregates
    """
    store = FeedbackStore(base_path=temp_dir)

    # Simulate 3 completed plans
    for plan_num in range(3):
        steps = 5 + plan_num  # 5, 6, 7 steps
        for step in range(steps):
            store.update_technique_stats(
                'service-impl', 'tdd', True, 2
            )
        store.update_metrics(
            completed_plans_delta=1,
            total_steps_delta=steps
        )

    metrics = store.get_metrics()
    assert metrics['completedPlans'] == 3
    assert metrics['totalSteps'] == 18  # 5+6+7
    # Average should be (5+6+7)/3 = 6
    assert abs(metrics['averageStepsPerPlan'] - 6.0) < 0.01
```

#### Scenario 5: Concurrent Access
```python
def test_concurrent_writes_dont_corrupt():
    """
    Test that concurrent writes are safe:
    1. Launch multiple threads
    2. All write to same store
    3. Data should not be corrupted
    """
    import threading

    store = FeedbackStore(base_path=temp_dir)

    def writer(thread_id):
        for i in range(10):
            store.update_technique_stats(
                f'type_{thread_id}',
                'tdd',
                True,
                1
            )

    threads = [
        threading.Thread(target=writer, args=(i,))
        for i in range(5)
    ]

    for t in threads:
        t.start()
    for t in threads:
        t.join()

    # Verify no corruption
    data = store.get_effectiveness_data()
    assert 'byProblemType' in data
    assert len(data['byProblemType']) == 5
```

#### Scenario 6: Cold Start to Full Operation
```python
def test_cold_start_to_full_operation():
    """
    Test full lifecycle from empty state:
    1. Start with no data
    2. Run through classification
    3. Execute steps
    4. Verify feedback recorded
    5. Verify selection adapts
    """
    temp_dir = create_temp_project()
    store = FeedbackStore(base_path=temp_dir)

    # Cold start - should use defaults
    tracker = EffectivenessTracker(store)
    selector = TechniqueSelector(effectiveness_tracker=tracker)

    result = selector.select_techniques('debug', Phase.IMPLEMENTATION)
    assert result.confidence == 0.5  # No data confidence

    # Simulate 15 step completions
    for i in range(15):
        success = i % 3 != 0  # 67% success
        tracker.record_outcome('debug', 'reflexion', success, 2)

    # Now should have learned
    result = selector.select_techniques('debug', Phase.IMPLEMENTATION)
    assert result.confidence > 0.5
```

### Test Fixtures

```python
@pytest.fixture
def temp_project():
    """Create a temporary project directory with feedback structure."""
    import tempfile
    import shutil

    temp_dir = tempfile.mkdtemp()
    planning_data = Path(temp_dir) / '.claude' / 'planning-data'
    planning_data.mkdir(parents=True)

    # Copy technique config
    shutil.copy(
        '.claude/technique-config.json',
        Path(temp_dir) / '.claude' / 'technique-config.json'
    )

    yield temp_dir

    # Cleanup
    shutil.rmtree(temp_dir)


@pytest.fixture
def populated_store(temp_project):
    """Create a store with sample data."""
    store = FeedbackStore(base_path=temp_project)

    # Add sample effectiveness data
    techniques = ['tdd', 'reflexion', 'self-refine']
    types = ['debug', 'ui', 'service-impl']

    for ptype in types:
        for tech in techniques:
            for _ in range(12):  # Above threshold
                success = random.random() > 0.3
                store.update_technique_stats(ptype, tech, success, 2)

    return store
```

### Performance Benchmarks

```python
def test_performance_large_dataset():
    """
    Test performance with large dataset:
    - 100 problem types
    - 10 techniques each
    - 1000 samples each
    """
    store = FeedbackStore(base_path=temp_dir)

    import time
    start = time.time()

    # Write performance
    for ptype in range(100):
        for tech in range(10):
            for _ in range(100):
                store.update_technique_stats(
                    f'type_{ptype}',
                    f'tech_{tech}',
                    True,
                    1
                )

    write_time = time.time() - start
    print(f"Write time: {write_time:.2f}s")
    assert write_time < 60  # Should complete in under a minute

    # Read performance
    start = time.time()
    data = store.get_effectiveness_data()
    read_time = time.time() - start
    print(f"Read time: {read_time:.2f}s")
    assert read_time < 5  # Should read in under 5 seconds

    # Query performance
    tracker = EffectivenessTracker(store)
    start = time.time()
    for _ in range(1000):
        tracker.get_effectiveness('type_50', 'tech_5')
    query_time = time.time() - start
    print(f"Query time (1000 queries): {query_time:.2f}s")
    assert query_time < 2
```

## Files to Create
- `.claude/tests/test_integration.py`: Integration tests

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/tests/test_integration.py` (existing) for test patterns

## Acceptance Criteria
- [ ] All integration tests pass
- [ ] Edge cases covered
- [ ] Performance benchmarks acceptable
- [ ] Concurrent access safe
- [ ] Full lifecycle tested

## Testing Requirements

### Integration Tests
- [ ] Test file: `.claude/tests/test_integration.py`
- [ ] Test cases: All scenarios above

### Coverage Targets
- Feedback Store: 90%+
- Effectiveness Tracker: 85%+
- Implementation Tracker: 85%+
- Classification History: 85%+

## Verification Commands
```bash
# Run all integration tests
cd .claude && python3 -m pytest tests/test_integration.py -v

# Run with coverage
cd .claude && python3 -m pytest tests/test_integration.py -v --cov=scripts --cov-report=html

# Run performance tests
cd .claude && python3 -m pytest tests/test_integration.py::test_performance_large_dataset -v -s
```

## Documentation Updates
- [ ] Document test coverage in README
- [ ] Add test running instructions to CLAUDE.md

## Error Recovery
If verification fails:
1. Isolate failing scenario
2. Check fixture setup
3. Test components individually

## Do NOT
- Skip edge case tests
- Ignore performance benchmarks
- Leave flaky tests
