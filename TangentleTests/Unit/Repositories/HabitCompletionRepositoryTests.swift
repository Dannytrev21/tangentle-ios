import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("HabitCompletionRepository Tests")
struct HabitCompletionRepositoryTests {

    // MARK: - Create Tests

    @Test("Create completion saves to context")
    func createCompletion() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")
        let completion = stack.createHabitCompletion(habit: habit, date: Date())

        try stack.save()

        let fetched = try await repo.fetchById(completion.id!)
        #expect(fetched != nil)
    }

    @Test("Create completion with custom count")
    func createCompletion_withCustomCount() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Drink Water")
        let completion = stack.createHabitCompletion(habit: habit, date: Date())
        completion.count = 8

        try stack.save()

        let fetched = try await repo.fetchById(completion.id!)
        #expect(fetched?.count == 8)
    }

    // MARK: - Fetch By Habit Tests

    @Test("Fetch by habit returns completions for specific habit")
    func fetchByHabit_returnsCompletions() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit1 = stack.createHabit(name: "Habit 1")
        let habit2 = stack.createHabit(name: "Habit 2")

        let c1 = stack.createHabitCompletion(habit: habit1, date: Date())
        let c2 = stack.createHabitCompletion(habit: habit1, date: Date.testYesterday)
        _ = stack.createHabitCompletion(habit: habit2, date: Date())

        try stack.save()

        let completions = try await repo.fetchByHabit(habit1)

        #expect(completions.count == 2)
        #expect(completions.allSatisfy { $0.habit == habit1 })
    }

    @Test("Fetch by habit returns empty for habit with no completions")
    func fetchByHabit_noCompletions_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "New Habit")

        try stack.save()

        let completions = try await repo.fetchByHabit(habit)

        #expect(completions.isEmpty)
    }

    @Test("Fetch by habit returns only completions for that habit")
    func fetchByHabit_onlyMatchingHabit() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit1 = stack.createHabit(name: "Habit 1")
        let habit2 = stack.createHabit(name: "Habit 2")

        _ = stack.createHabitCompletion(habit: habit1, date: Date())
        _ = stack.createHabitCompletion(habit: habit2, date: Date())
        _ = stack.createHabitCompletion(habit: habit2, date: Date.testYesterday)

        try stack.save()

        let habit1Completions = try await repo.fetchByHabit(habit1)
        let habit2Completions = try await repo.fetchByHabit(habit2)

        #expect(habit1Completions.count == 1)
        #expect(habit2Completions.count == 2)
    }

    // MARK: - Fetch For Date Tests

    @Test("Fetch for date filters by date and habit")
    func fetchForDate_filtersByDateAndHabit() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")

        // Create completion today
        let todayCompletion = stack.createHabitCompletion(habit: habit, date: Date.testToday)

        // Create completion yesterday
        _ = stack.createHabitCompletion(habit: habit, date: Date.testYesterday)

        try stack.save()

        let todayCompletions = try await repo.fetchForDate(Date.testToday, habit: habit)

        #expect(todayCompletions.count == 1)
        #expect(todayCompletions.first?.id == todayCompletion.id)
    }

    @Test("Fetch for date returns empty when no completion exists")
    func fetchForDate_noCompletion_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")

        try stack.save()

        let completions = try await repo.fetchForDate(Date.testToday, habit: habit)

        #expect(completions.isEmpty)
    }

    @Test("Fetch for date with different habit returns empty")
    func fetchForDate_differentHabit_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit1 = stack.createHabit(name: "Habit 1")
        let habit2 = stack.createHabit(name: "Habit 2")

        _ = stack.createHabitCompletion(habit: habit1, date: Date.testToday)

        try stack.save()

        let completions = try await repo.fetchForDate(Date.testToday, habit: habit2)

        #expect(completions.isEmpty)
    }

    @Test("Fetch for date with different date returns empty")
    func fetchForDate_differentDate_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")
        _ = stack.createHabitCompletion(habit: habit, date: Date.testYesterday)

        try stack.save()

        let completions = try await repo.fetchForDate(Date.testToday, habit: habit)

        #expect(completions.isEmpty)
    }

    // MARK: - Delete Tests

    @Test("Delete completion removes from context")
    func deleteCompletion() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")
        let completion = stack.createHabitCompletion(habit: habit, date: Date())
        let completionId = completion.id!

        try stack.save()

        try await repo.delete(completion)

        let fetched = try await repo.fetchById(completionId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct completion")
    func fetchById_returnsCompletion() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Test Habit")
        let completion = stack.createHabitCompletion(habit: habit, date: Date())
        let completionId = completion.id!

        try stack.save()

        let fetched = try await repo.fetchById(completionId)

        #expect(fetched != nil)
        #expect(fetched?.id == completionId)
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Multiple completions same day")
    func fetchForDate_multipleCompletionsSameDay() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Drink Water")
        habit.targetCount = 8

        // Multiple completions on the same day
        _ = stack.createHabitCompletion(habit: habit, date: Date.testToday)
        _ = stack.createHabitCompletion(habit: habit, date: Date.testToday)

        try stack.save()

        let completions = try await repo.fetchForDate(Date.testToday, habit: habit)

        #expect(completions.count == 2)
    }

    @Test("Empty database returns empty array")
    func fetchByHabit_emptyDatabase() async throws {
        let stack = TestCoreDataStack()
        let repo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Empty Habit")

        try stack.save()

        let completions = try await repo.fetchByHabit(habit)

        #expect(completions.isEmpty)
    }
}
