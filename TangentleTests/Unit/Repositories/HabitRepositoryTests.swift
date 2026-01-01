import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("HabitRepository Tests")
struct HabitRepositoryTests {

    // MARK: - Create Tests

    @Test("Create habit saves to context")
    func createHabit() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Exercise", frequency: .daily)

        try stack.save()

        let fetched = try await repo.fetchById(habit.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Exercise")
    }

    @Test("Create habit with weekly frequency")
    func createHabit_weeklyFrequency() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Weekly Review", frequency: .weekly)

        try stack.save()

        let fetched = try await repo.fetchById(habit.id!)
        #expect(fetched?.habitFrequency == .weekly)
    }

    // MARK: - Fetch Active Tests

    @Test("Fetch active returns active habits only")
    func fetchActive_returnsActiveOnly() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let active = stack.createHabit(name: "Active Habit")
        active.isActive = true
        let inactive = stack.createHabit(name: "Inactive Habit")
        inactive.isActive = false

        try stack.save()

        let habits = try await repo.fetchActive()

        #expect(habits.count == 1)
        #expect(habits.first?.name == "Active Habit")
    }

    @Test("Fetch active returns empty when none active")
    func fetchActive_noneActive_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let inactive = stack.createHabit(name: "Inactive")
        inactive.isActive = false

        try stack.save()

        let habits = try await repo.fetchActive()

        #expect(habits.isEmpty)
    }

    @Test("Fetch active returns multiple active habits")
    func fetchActive_multipleActive() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        _ = stack.createHabit(name: "Habit 1")
        _ = stack.createHabit(name: "Habit 2")
        _ = stack.createHabit(name: "Habit 3")

        try stack.save()

        let habits = try await repo.fetchActive()

        #expect(habits.count == 3)
    }

    @Test("Fetch active sorts by name")
    func fetchActive_sortsByName() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        _ = stack.createHabit(name: "Zebra Habit")
        _ = stack.createHabit(name: "Alpha Habit")
        _ = stack.createHabit(name: "Beta Habit")

        try stack.save()

        let habits = try await repo.fetchActive()

        #expect(habits[0].name == "Alpha Habit")
        #expect(habits[1].name == "Beta Habit")
        #expect(habits[2].name == "Zebra Habit")
    }

    // MARK: - Fetch Due Today Tests

    @Test("Fetch due today returns daily habits not completed today")
    func fetchDueToday_returnsDailyHabits() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let daily = stack.createHabit(name: "Daily Habit", frequency: .daily)
        daily.isActive = true
        // No lastCompletedAt means not completed today

        try stack.save()

        let habits = try await repo.fetchDueToday()

        #expect(habits.contains { $0.name == "Daily Habit" })
    }

    @Test("Fetch due today excludes habits completed today")
    func fetchDueToday_excludesCompletedToday() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let completedHabit = stack.createHabit(name: "Completed Habit", frequency: .daily)
        completedHabit.isActive = true
        completedHabit.lastCompletedAt = Date() // Completed today

        let notCompletedHabit = stack.createHabit(name: "Not Completed", frequency: .daily)
        notCompletedHabit.isActive = true
        notCompletedHabit.lastCompletedAt = nil // Never completed

        try stack.save()

        let habits = try await repo.fetchDueToday()

        #expect(habits.count == 1)
        #expect(habits.first?.name == "Not Completed")
    }

    @Test("Fetch due today excludes inactive habits")
    func fetchDueToday_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let inactive = stack.createHabit(name: "Inactive Habit")
        inactive.isActive = false

        try stack.save()

        let habits = try await repo.fetchDueToday()

        #expect(habits.isEmpty)
    }

    @Test("Fetch due today returns empty when all completed")
    func fetchDueToday_allCompleted_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Completed")
        habit.isActive = true
        habit.lastCompletedAt = Date()

        try stack.save()

        let habits = try await repo.fetchDueToday()

        #expect(habits.isEmpty)
    }

    // MARK: - Fetch By Frequency Tests

    @Test("Fetch by frequency filters correctly")
    func fetchByFrequency_filtersCorrectly() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        _ = stack.createHabit(name: "Daily", frequency: .daily)
        _ = stack.createHabit(name: "Weekly", frequency: .weekly)

        try stack.save()

        let daily = try await repo.fetchByFrequency(.daily)

        #expect(daily.count == 1)
        #expect(daily.first?.name == "Daily")
    }

    @Test("Fetch by frequency returns empty for no matches")
    func fetchByFrequency_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        _ = stack.createHabit(name: "Daily Habit", frequency: .daily)

        try stack.save()

        let weekly = try await repo.fetchByFrequency(.weekly)

        #expect(weekly.isEmpty)
    }

    @Test("Fetch by frequency excludes inactive")
    func fetchByFrequency_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let activeDaily = stack.createHabit(name: "Active Daily", frequency: .daily)
        activeDaily.isActive = true

        let inactiveDaily = stack.createHabit(name: "Inactive Daily", frequency: .daily)
        inactiveDaily.isActive = false

        try stack.save()

        let daily = try await repo.fetchByFrequency(.daily)

        #expect(daily.count == 1)
        #expect(daily.first?.name == "Active Daily")
    }

    // MARK: - Delete Tests

    @Test("Delete habit removes from context")
    func deleteHabit() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "To Delete")
        let habitId = habit.id!

        try stack.save()

        try await repo.delete(habit)

        let fetched = try await repo.fetchById(habitId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct habit")
    func fetchById_returnsHabit() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Find Me")
        let habitId = habit.id!

        try stack.save()

        let fetched = try await repo.fetchById(habitId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchActive_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habits = try await repo.fetchActive()

        #expect(habits.isEmpty)
    }

    @Test("Habit with target count")
    func createHabit_withTargetCount() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Drink Water")
        habit.targetCount = 8

        try stack.save()

        let fetched = try await repo.fetchById(habit.id!)
        #expect(fetched?.targetCount == 8)
    }

    @Test("Habit with streak")
    func habitWithStreak() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitRepository(context: stack.context)

        let habit = stack.createHabit(name: "Meditation")
        habit.streakCount = 30

        try stack.save()

        let fetched = try await repo.fetchById(habit.id!)
        #expect(fetched?.streakCount == 30)
    }
}
