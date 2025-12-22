import Foundation
import CoreData

final class ProjectRepository: BaseRepository<TGProject>, ProjectRepositoryProtocol {

    override func fetchActive() async throws -> [TGProject] {
        let predicate = NSPredicate(format: "isActive == YES")
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchByGoal(_ goal: TGGoal) async throws -> [TGProject] {
        let predicate = NSPredicate(format: "goal == %@", goal)
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchArchived() async throws -> [TGProject] {
        let predicate = NSPredicate(format: "isActive == NO")
        let sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
