import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("SeedDataService Tests")
struct SeedDataServiceTests {

    // MARK: - Seed If Needed Tests

    @Test("Seed if needed creates strategies on first launch")
    func seedIfNeeded_createsStrategies() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let count = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.count(for: request)
        }

        #expect(count > 0)
    }

    @Test("Seed if needed creates problem types on first launch")
    func seedIfNeeded_createsProblemTypes() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let count = try await stack.context.perform {
            let request = TGProblemType.fetchRequest()
            return try stack.context.count(for: request)
        }

        #expect(count > 0)
    }

    @Test("Seed if needed creates focus modes on first launch")
    func seedIfNeeded_createsFocusModes() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let count = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            return try stack.context.count(for: request)
        }

        #expect(count > 0)
    }

    @Test("Seed if needed creates settings on first launch")
    func seedIfNeeded_createsSettings() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let count = try await stack.context.perform {
            let request = TGSettings.fetchRequest()
            return try stack.context.count(for: request)
        }

        #expect(count > 0)
    }

    @Test("Seed if needed does not duplicate on subsequent calls")
    func seedIfNeeded_noDuplicates() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        // Seed twice
        try await service.seedIfNeeded()
        let countAfterFirst = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.count(for: request)
        }

        try await service.seedIfNeeded()
        let countAfterSecond = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.count(for: request)
        }

        #expect(countAfterFirst == countAfterSecond)
    }

    @Test("Seed if needed skips when data exists")
    func seedIfNeeded_skipsWhenExists() async throws {
        let stack = TestCoreDataStack()

        // Manually create a strategy first
        _ = stack.createStrategy(name: "Existing Strategy")
        try stack.save()

        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.fetch(request)
        }

        // Should only have the one we created
        #expect(strategies.count == 1)
        #expect(strategies.first?.name == "Existing Strategy")
    }

    // MARK: - Default Strategies Tests

    @Test("Default strategies includes 2-Minute Version")
    func defaultStrategies_includes2MinuteVersion() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", "2-Minute Version")
            return try stack.context.fetch(request)
        }

        #expect(strategies.count == 1)
        #expect(strategies.first?.problemTypes?.contains("too_big") == true)
    }

    @Test("Default strategies includes First Step Only")
    func defaultStrategies_includesFirstStepOnly() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", "First Step Only")
            return try stack.context.fetch(request)
        }

        #expect(strategies.count == 1)
    }

    @Test("Default strategies includes Pomodoro")
    func defaultStrategies_includesPomodoro() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS %@", "Pomodoro")
            return try stack.context.fetch(request)
        }

        #expect(strategies.count >= 1)
    }

    @Test("Default strategies have source set to 'default'")
    func defaultStrategies_haveDefaultSource() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.fetch(request)
        }

        #expect(strategies.allSatisfy { $0.source == "default" })
    }

    @Test("Default strategies are active")
    func defaultStrategies_areActive() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let strategies = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.fetch(request)
        }

        #expect(strategies.allSatisfy { $0.isActive == true })
    }

    // MARK: - Default Problem Types Tests

    @Test("Default problem types includes 'too_big'")
    func defaultProblemTypes_includesTooBig() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let types = try await stack.context.perform {
            let request = TGProblemType.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@", "too_big")
            return try stack.context.fetch(request)
        }

        #expect(types.count == 1)
        #expect(types.first?.label == "Too Big")
    }

    @Test("Default problem types includes all expected types")
    func defaultProblemTypes_includesAll() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let types = try await stack.context.perform {
            let request = TGProblemType.fetchRequest()
            return try stack.context.fetch(request)
        }

        let expectedTypes = ["too_big", "unclear", "boring", "scary", "blocked",
                            "distracted", "low_energy", "overwhelmed", "forgot",
                            "interruptions", "other"]

        let identifiers = types.map { $0.identifier }
        for expected in expectedTypes {
            #expect(identifiers.contains(expected))
        }
    }

    @Test("Default problem types are marked as default")
    func defaultProblemTypes_areMarkedDefault() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let types = try await stack.context.perform {
            let request = TGProblemType.fetchRequest()
            return try stack.context.fetch(request)
        }

        #expect(types.allSatisfy { $0.isDefault == true })
    }

    @Test("Default problem types have sort order")
    func defaultProblemTypes_haveSortOrder() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let types = try await stack.context.perform {
            let request = TGProblemType.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TGProblemType.sortOrder, ascending: true)]
            return try stack.context.fetch(request)
        }

        // First should be 'too_big' (index 0)
        #expect(types.first?.identifier == "too_big")
        #expect(types.first?.sortOrder == 0)
    }

    // MARK: - Default Focus Modes Tests

    @Test("Default focus modes includes Morning")
    func defaultFocusModes_includesMorning() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let modes = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", "Morning")
            return try stack.context.fetch(request)
        }

        #expect(modes.count == 1)
    }

    @Test("Default focus modes includes Peak Focus")
    func defaultFocusModes_includesPeakFocus() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let modes = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", "Peak Focus")
            return try stack.context.fetch(request)
        }

        #expect(modes.count == 1)
    }

    @Test("Default focus modes includes Weekend")
    func defaultFocusModes_includesWeekend() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let modes = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", "Weekend")
            return try stack.context.fetch(request)
        }

        #expect(modes.count == 1)
        // Weekend should apply to Saturday and Sunday
        let weekendMode = modes.first
        #expect(weekendMode?.daysOfWeek?.contains(1) == true) // Sunday
        #expect(weekendMode?.daysOfWeek?.contains(7) == true) // Saturday
    }

    @Test("Default focus modes are active")
    func defaultFocusModes_areActive() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let modes = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            return try stack.context.fetch(request)
        }

        #expect(modes.allSatisfy { $0.isActive == true })
    }

    @Test("Default focus modes are automatic")
    func defaultFocusModes_areAutomatic() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()

        let modes = try await stack.context.perform {
            let request = TGFocusMode.fetchRequest()
            return try stack.context.fetch(request)
        }

        #expect(modes.allSatisfy { $0.isAutomatic == true })
    }

    // MARK: - Edge Cases

    @Test("Seed handles empty context")
    func seedIfNeeded_emptyContext() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        // Should not throw
        try await service.seedIfNeeded()

        #expect(Bool(true)) // If we got here, it didn't throw
    }

    @Test("Multiple seeds do not increase count")
    func multipleSeeds_noIncrease() async throws {
        let stack = TestCoreDataStack()
        let service = SeedDataService(context: stack.context)

        try await service.seedIfNeeded()
        try await service.seedIfNeeded()
        try await service.seedIfNeeded()

        let count = try await stack.context.perform {
            let request = TGStrategy.fetchRequest()
            return try stack.context.count(for: request)
        }

        // Should be same as one seed
        #expect(count == SeedDataService.defaultStrategies.count)
    }
}
