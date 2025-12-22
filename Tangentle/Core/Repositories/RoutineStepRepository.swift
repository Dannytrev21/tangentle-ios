import Foundation
import CoreData

final class RoutineStepRepository: BaseRepository<TGRoutineStep>, RoutineStepRepositoryProtocol {

    func fetchByRoutine(_ routine: TGRoutine) async throws -> [TGRoutineStep] {
        let predicate = NSPredicate(format: "routine == %@", routine)
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
