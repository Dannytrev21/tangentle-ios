import Foundation
import CoreData

extension TGHabit {
    // MARK: - Computed Properties

    var habitFrequency: HabitFrequency {
        get { HabitFrequency(rawValue: frequency ?? "daily") ?? .daily }
        set { frequency = newValue.rawValue }
    }

    var completionsArray: [TGHabitCompletion] {
        let set = completions as? Set<TGHabitCompletion> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    var isCompletedToday: Bool {
        guard let last = lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var todayCompletionCount: Int16 {
        let today = Calendar.current.startOfDay(for: Date())
        let todayCompletions = completionsArray.filter { completion in
            guard let date = completion.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }
        return todayCompletions.reduce(0) { $0 + $1.count }
    }

    var isTargetMetToday: Bool {
        todayCompletionCount >= targetCount
    }

    var currentStreakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        // If not completed today, start checking from yesterday
        if !isCompletedToday {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }

        let completionDates = Set(completionsArray.compactMap { completion -> Date? in
            guard let date = completion.date else { return nil }
            return calendar.startOfDay(for: date)
        })

        while completionDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streak
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        frequency: HabitFrequency = .daily,
        targetCount: Int16 = 1
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.habitFrequency = frequency
        self.targetCount = targetCount
        self.isActive = true
        self.streakCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func complete(count: Int16 = 1) {
        guard let context = managedObjectContext else { return }

        let completion = TGHabitCompletion(context: context)
        completion.id = UUID()
        completion.habit = self
        completion.date = Date()
        completion.count = count

        lastCompletedAt = Date()
        streakCount = Int32(currentStreakDays)
        updatedAt = Date()
    }

    func resetStreak() {
        streakCount = 0
        updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGHabitCompletion Extension

extension TGHabitCompletion {
    convenience init(
        context: NSManagedObjectContext,
        habit: TGHabit,
        count: Int16 = 1
    ) {
        self.init(context: context)
        self.id = UUID()
        self.habit = habit
        self.date = Date()
        self.count = count
    }
}
