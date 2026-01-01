import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("RoutineRepository Tests")
struct RoutineRepositoryTests {

    // MARK: - Create Tests

    @Test("Create routine saves to context")
    func createRoutine() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let routine = repo.create()
        routine.id = UUID()
        routine.name = "Morning Routine"
        routine.routineType = RoutineType.morning.rawValue
        routine.isEnabled = true
        routine.daysOfWeek = [1, 2, 3, 4, 5]
        routine.estimatedDuration = 30
        routine.createdAt = Date()
        routine.updatedAt = Date()

        try await repo.save()

        let fetched = try await repo.fetchById(routine.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Morning Routine")
    }

    // MARK: - Fetch Enabled Tests

    @Test("Fetch enabled returns only enabled routines")
    func fetchEnabled_returnsOnlyEnabled() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let enabled = stack.createRoutine(name: "Enabled Routine")
        enabled.isEnabled = true
        let disabled = stack.createRoutine(name: "Disabled Routine")
        disabled.isEnabled = false

        try stack.save()

        let routines = try await repo.fetchEnabled()

        #expect(routines.count == 1)
        #expect(routines.first?.name == "Enabled Routine")
    }

    @Test("Fetch enabled returns empty when none enabled")
    func fetchEnabled_noneEnabled_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let disabled = stack.createRoutine(name: "Disabled")
        disabled.isEnabled = false

        try stack.save()

        let routines = try await repo.fetchEnabled()

        #expect(routines.isEmpty)
    }

    @Test("Fetch enabled returns multiple enabled routines")
    func fetchEnabled_multipleEnabled() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        _ = stack.createRoutine(name: "Routine 1")
        _ = stack.createRoutine(name: "Routine 2")
        _ = stack.createRoutine(name: "Routine 3")

        try stack.save()

        let routines = try await repo.fetchEnabled()

        #expect(routines.count == 3)
    }

    // MARK: - Fetch By Type Tests

    @Test("Fetch by type filters correctly")
    func fetchByType_filtersCorrectly() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        _ = stack.createRoutine(name: "Morning", type: .morning)
        _ = stack.createRoutine(name: "Evening", type: .evening)
        _ = stack.createRoutine(name: "Custom", type: .custom)

        try stack.save()

        let mornings = try await repo.fetchByType(.morning)

        #expect(mornings.count == 1)
        #expect(mornings.first?.name == "Morning")
    }

    @Test("Fetch by type returns empty for no matches")
    func fetchByType_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        _ = stack.createRoutine(name: "Morning Routine", type: .morning)

        try stack.save()

        let evenings = try await repo.fetchByType(.evening)

        #expect(evenings.isEmpty)
    }

    @Test("Fetch by type returns multiple routines of same type")
    func fetchByType_multipleOfSameType() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        _ = stack.createRoutine(name: "Morning 1", type: .morning)
        _ = stack.createRoutine(name: "Morning 2", type: .morning)
        _ = stack.createRoutine(name: "Evening", type: .evening)

        try stack.save()

        let mornings = try await repo.fetchByType(.morning)

        #expect(mornings.count == 2)
    }

    // MARK: - Fetch Scheduled For Today Tests

    @Test("Fetch scheduled for today returns matching routines")
    func fetchScheduledForToday_returnsMatching() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let today = Calendar.current.component(.weekday, from: Date())
        let scheduled = stack.createRoutine(name: "Today Routine")
        scheduled.daysOfWeek = [today]
        scheduled.isEnabled = true

        let notScheduled = stack.createRoutine(name: "Other Day")
        // Set to a different day (wrap around if needed)
        let otherDay = today == 7 ? 1 : today + 1
        notScheduled.daysOfWeek = [otherDay]
        notScheduled.isEnabled = true

        try stack.save()

        let routines = try await repo.fetchScheduledForToday()

        #expect(routines.count == 1)
        #expect(routines.first?.name == "Today Routine")
    }

    @Test("Fetch scheduled for today excludes disabled routines")
    func fetchScheduledForToday_excludesDisabled() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let today = Calendar.current.component(.weekday, from: Date())
        let enabled = stack.createRoutine(name: "Enabled")
        enabled.daysOfWeek = [today]
        enabled.isEnabled = true

        let disabled = stack.createRoutine(name: "Disabled")
        disabled.daysOfWeek = [today]
        disabled.isEnabled = false

        try stack.save()

        let routines = try await repo.fetchScheduledForToday()

        #expect(routines.count == 1)
        #expect(routines.first?.name == "Enabled")
    }

    @Test("Fetch scheduled for today returns empty when none scheduled")
    func fetchScheduledForToday_noneScheduled_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let today = Calendar.current.component(.weekday, from: Date())
        let otherDay = today == 7 ? 1 : today + 1

        let routine = stack.createRoutine(name: "Other Day Routine")
        routine.daysOfWeek = [otherDay]
        routine.isEnabled = true

        try stack.save()

        let routines = try await repo.fetchScheduledForToday()

        #expect(routines.isEmpty)
    }

    // MARK: - Delete Tests

    @Test("Delete routine removes from context")
    func deleteRoutine() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let routine = stack.createRoutine(name: "To Delete")
        let routineId = routine.id!

        try stack.save()

        try await repo.delete(routine)

        let fetched = try await repo.fetchById(routineId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct routine")
    func fetchById_returnsRoutine() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Find Me")
        let routineId = routine.id!

        try stack.save()

        let fetched = try await repo.fetchById(routineId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchEnabled_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let routines = try await repo.fetchEnabled()

        #expect(routines.isEmpty)
    }

    @Test("Routine with no steps")
    func routineWithNoSteps() async throws {
        let stack = TestCoreDataStack()
        let repo = RoutineRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Empty Routine")

        try stack.save()

        let fetched = try await repo.fetchById(routine.id!)
        #expect(fetched != nil)
        #expect(fetched?.stepsArray.isEmpty == true)
    }
}
