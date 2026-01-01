import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("RoutineStepRepository Tests")
struct RoutineStepRepositoryTests {

    // MARK: - Create Tests

    @Test("Create step saves to context")
    func createStep() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        let step = stack.createRoutineStep(name: "Step 1", order: 0, routine: routine)

        try stack.save()

        let fetched = try await repo.fetchById(step.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Step 1")
    }

    @Test("Create step with custom duration")
    func createStep_withCustomDuration() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        let step = stack.createRoutineStep(name: "Long Step", order: 0, routine: routine)
        step.estimatedDuration = 15

        try stack.save()

        let fetched = try await repo.fetchById(step.id!)
        #expect(fetched?.estimatedDuration == 15)
    }

    // MARK: - Fetch By Routine Tests

    @Test("Fetch by routine returns steps in order")
    func fetchByRoutine_returnsInOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        _ = stack.createRoutineStep(name: "Step 3", order: 2, routine: routine)
        _ = stack.createRoutineStep(name: "Step 1", order: 0, routine: routine)
        _ = stack.createRoutineStep(name: "Step 2", order: 1, routine: routine)

        try stack.save()

        let steps = try await repo.fetchByRoutine(routine)

        #expect(steps.count == 3)
        #expect(steps[0].name == "Step 1")
        #expect(steps[1].name == "Step 2")
        #expect(steps[2].name == "Step 3")
    }

    @Test("Fetch by routine returns empty for routine with no steps")
    func fetchByRoutine_noSteps_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Empty Routine")

        try stack.save()

        let steps = try await repo.fetchByRoutine(routine)

        #expect(steps.isEmpty)
    }

    @Test("Fetch by routine returns only steps for that routine")
    func fetchByRoutine_onlyMatchingRoutine() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine1 = stack.createRoutine(name: "Routine 1")
        let routine2 = stack.createRoutine(name: "Routine 2")

        _ = stack.createRoutineStep(name: "R1 Step 1", order: 0, routine: routine1)
        _ = stack.createRoutineStep(name: "R1 Step 2", order: 1, routine: routine1)
        _ = stack.createRoutineStep(name: "R2 Step 1", order: 0, routine: routine2)

        try stack.save()

        let routine1Steps = try await repo.fetchByRoutine(routine1)
        let routine2Steps = try await repo.fetchByRoutine(routine2)

        #expect(routine1Steps.count == 2)
        #expect(routine2Steps.count == 1)
        #expect(routine1Steps.allSatisfy { $0.routine == routine1 })
        #expect(routine2Steps.allSatisfy { $0.routine == routine2 })
    }

    @Test("Routine with many steps maintains order")
    func fetchByRoutine_manySteps_maintainsOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Long Routine")

        // Create steps in reverse order
        for i in (0..<20).reversed() {
            _ = stack.createRoutineStep(name: "Step \(i)", order: Int32(i), routine: routine)
        }

        try stack.save()

        let steps = try await repo.fetchByRoutine(routine)

        #expect(steps.count == 20)
        for (index, step) in steps.enumerated() {
            #expect(step.sortOrder == Int32(index))
        }
    }

    // MARK: - Delete Tests

    @Test("Delete step removes from context")
    func deleteStep() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        let step = stack.createRoutineStep(name: "To Delete", order: 0, routine: routine)
        let stepId = step.id!

        try stack.save()

        try await repo.delete(step)

        let fetched = try await repo.fetchById(stepId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct step")
    func fetchById_returnsStep() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        let step = stack.createRoutineStep(name: "Find Me", order: 0, routine: routine)
        let stepId = step.id!

        try stack.save()

        let fetched = try await repo.fetchById(stepId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array for fetch by routine")
    func fetchByRoutine_emptyDatabase() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        // Create routine but no steps
        let routine = stack.createRoutine(name: "Empty Routine")

        try stack.save()

        let steps = try await repo.fetchByRoutine(routine)

        #expect(steps.isEmpty)
    }

    @Test("Steps with same order maintain consistent retrieval")
    func fetchByRoutine_sameOrder_consistentRetrieval() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Test Routine")
        _ = stack.createRoutineStep(name: "Step A", order: 0, routine: routine)
        _ = stack.createRoutineStep(name: "Step B", order: 0, routine: routine)

        try stack.save()

        let first = try await repo.fetchByRoutine(routine)
        let second = try await repo.fetchByRoutine(routine)

        // Order should be consistent between calls
        #expect(first.map { $0.id } == second.map { $0.id })
    }
}
