import Foundation
import CoreData

extension TGRoutine {
    // MARK: - Computed Properties

    var routineTypeEnum: RoutineType {
        get { RoutineType(rawValue: routineType ?? "morning") ?? .morning }
        set { routineType = newValue.rawValue }
    }

    var daysOfWeekArray: [DayOfWeek] {
        get {
            let intArray = daysOfWeek ?? []
            return intArray.compactMap { DayOfWeek(rawValue: $0) }
        }
        set {
            daysOfWeek = newValue.map { $0.rawValue }
        }
    }

    var stepsArray: [TGRoutineStep] {
        // Steps are ordered, so we can use the ordered set
        guard let orderedSet = steps else { return [] }
        return orderedSet.array as? [TGRoutineStep] ?? []
    }

    var linkedTasksArray: [TGTask] {
        let set = linkedTasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var totalEstimatedDuration: Int16 {
        stepsArray.reduce(0) { $0 + $1.estimatedDuration }
    }

    var isScheduledToday: Bool {
        let today = Calendar.current.component(.weekday, from: Date())
        return daysOfWeekArray.contains { $0.rawValue == today }
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        routineType: RoutineType = .morning,
        scheduledTime: Date,
        daysOfWeek: [DayOfWeek] = DayOfWeek.allCases
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.routineTypeEnum = routineType
        self.scheduledTime = scheduledTime
        self.daysOfWeekArray = daysOfWeek
        self.estimatedDuration = 30
        self.isEnabled = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func addStep(name: String, duration: Int16 = 5) {
        guard let context = managedObjectContext else { return }

        let step = TGRoutineStep(context: context)
        step.id = UUID()
        step.name = name
        step.estimatedDuration = duration
        step.sortOrder = Int32(stepsArray.count)
        step.routine = self

        // Recalculate total duration
        estimatedDuration = totalEstimatedDuration + duration
        updatedAt = Date()
    }

    func removeStep(_ step: TGRoutineStep) {
        guard let context = managedObjectContext else { return }
        context.delete(step)
        estimatedDuration = totalEstimatedDuration
        updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGRoutineStep Extension

extension TGRoutineStep {
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        duration: Int16 = 5,
        routine: TGRoutine
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.estimatedDuration = duration
        self.sortOrder = Int32(routine.stepsArray.count)
        self.routine = routine
    }
}
