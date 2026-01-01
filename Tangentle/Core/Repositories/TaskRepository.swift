import Foundation
import CoreData

final class TaskRepository: BaseRepository<TGTask>, TaskRepositoryProtocol {

    func fetchTodaysTasks() async throws -> [TGTask] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = NSPredicate(
            format: "scheduledDate >= %@ AND scheduledDate < %@ AND status != %@",
            startOfDay as NSDate,
            endOfDay as NSDate,
            TaskStatus.done.rawValue
        )

        let sortDescriptors = [
            NSSortDescriptor(key: "scheduledTime", ascending: true),
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ]

        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchOverdueTasks() async throws -> [TGTask] {
        let now = Date()
        let predicate = NSPredicate(
            format: "dueDate < %@ AND status != %@",
            now as NSDate,
            TaskStatus.done.rawValue
        )

        let sortDescriptors = [
            NSSortDescriptor(key: "dueDate", ascending: true),
            NSSortDescriptor(key: "priority", ascending: false)
        ]

        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchByProject(_ project: TGProject) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "project == %@", project)
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchByStatus(_ status: TaskStatus) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "status == %@", status.rawValue)
        return try await fetch(predicate: predicate)
    }

    func fetchByPriority(_ priority: Priority) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "priority == %d", priority.rawValue)
        let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchScheduledBetween(start: Date, end: Date) async throws -> [TGTask] {
        let predicate = NSPredicate(
            format: "scheduledDate >= %@ AND scheduledDate < %@",
            start as NSDate,
            end as NSDate
        )

        let sortDescriptors = [
            NSSortDescriptor(key: "scheduledDate", ascending: true),
            NSSortDescriptor(key: "scheduledTime", ascending: true)
        ]

        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchPending() async throws -> [TGTask] {
        let predicate = NSPredicate(format: "status == %@", TaskStatus.pending.rawValue)
        let sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchInProgress() async throws -> [TGTask] {
        let predicate = NSPredicate(format: "status == %@", TaskStatus.inProgress.rawValue)
        return try await fetch(predicate: predicate)
    }

    func fetchByEnergy(_ energy: EnergyLevel) async throws -> [TGTask] {
        let predicate = NSPredicate(
            format: "energyRequired == %@ AND status != %@",
            energy.rawValue,
            TaskStatus.done.rawValue
        )
        return try await fetch(predicate: predicate)
    }
}
