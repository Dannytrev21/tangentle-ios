import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("ModeRepository Tests")
struct ModeRepositoryTests {

    // MARK: - Create Tests

    @Test("Create mode saves to context")
    func createMode() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "Work Mode", isDefault: false)

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Work Mode")
    }

    @Test("Create default mode")
    func createMode_asDefault() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "Default Mode", isDefault: true)

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched?.isDefault == true)
    }

    // MARK: - Fetch Default Tests

    @Test("Fetch default returns the default mode")
    func fetchDefault_returnsDefaultMode() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        _ = stack.createMode(name: "Regular", isDefault: false)
        let defaultMode = stack.createMode(name: "Default", isDefault: true)

        try stack.save()

        let fetched = try await repo.fetchDefault()

        #expect(fetched != nil)
        #expect(fetched?.name == "Default")
        #expect(fetched?.id == defaultMode.id)
    }

    @Test("Fetch default returns nil when no default set")
    func fetchDefault_noDefault_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        _ = stack.createMode(name: "Not Default", isDefault: false)

        try stack.save()

        let fetched = try await repo.fetchDefault()

        #expect(fetched == nil)
    }

    @Test("Fetch default returns nil when database empty")
    func fetchDefault_emptyDatabase_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let fetched = try await repo.fetchDefault()

        #expect(fetched == nil)
    }

    // MARK: - Fetch All Tests

    @Test("Fetch all returns all modes")
    func fetchAll_returnsAllModes() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        _ = stack.createMode(name: "Mode 1")
        _ = stack.createMode(name: "Mode 2")
        _ = stack.createMode(name: "Mode 3")

        try stack.save()

        let modes = try await repo.fetchAll()

        #expect(modes.count == 3)
    }

    @Test("Fetch all returns empty when no modes")
    func fetchAll_noModes_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let modes = try await repo.fetchAll()

        #expect(modes.isEmpty)
    }

    @Test("Fetch all includes both default and non-default modes")
    func fetchAll_includesDefaultAndNonDefault() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        _ = stack.createMode(name: "Default Mode", isDefault: true)
        _ = stack.createMode(name: "Regular Mode", isDefault: false)

        try stack.save()

        let modes = try await repo.fetchAll()

        #expect(modes.count == 2)
    }

    @Test("Fetch all sorts by name")
    func fetchAll_sortsByName() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        _ = stack.createMode(name: "Zebra Mode")
        _ = stack.createMode(name: "Alpha Mode")
        _ = stack.createMode(name: "Beta Mode")

        try stack.save()

        let modes = try await repo.fetchAll()

        #expect(modes[0].name == "Alpha Mode")
        #expect(modes[1].name == "Beta Mode")
        #expect(modes[2].name == "Zebra Mode")
    }

    // MARK: - Delete Tests

    @Test("Delete mode removes from context")
    func deleteMode() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "To Delete")
        let modeId = mode.id!

        try stack.save()

        try await repo.delete(mode)

        let fetched = try await repo.fetchById(modeId)
        #expect(fetched == nil)
    }

    @Test("Delete default mode works")
    func deleteMode_defaultMode() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let defaultMode = stack.createMode(name: "Default", isDefault: true)
        let modeId = defaultMode.id!

        try stack.save()

        try await repo.delete(defaultMode)

        let fetched = try await repo.fetchById(modeId)
        #expect(fetched == nil)

        let newDefault = try await repo.fetchDefault()
        #expect(newDefault == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct mode")
    func fetchById_returnsMode() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "Find Me")
        let modeId = mode.id!

        try stack.save()

        let fetched = try await repo.fetchById(modeId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchAll_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let modes = try await repo.fetchAll()

        #expect(modes.isEmpty)
    }

    @Test("Mode with description")
    func modeWithDescription() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "Work Mode")
        mode.modeDescription = "For deep work sessions"

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched?.modeDescription == "For deep work sessions")
    }

    @Test("Mode with shared flag")
    func modeWithSharedFlag() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        let mode = stack.createMode(name: "Shared Mode")
        mode.isShared = true

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched?.isShared == true)
    }

    @Test("Multiple defaults returns only one")
    func fetchDefault_multipleDefaults_returnsOne() async throws {
        let stack = TestCoreDataStack()
        let repo = ModeRepository(context: stack.context)

        // In a real scenario, application logic should prevent multiple defaults
        // but the repository should handle it gracefully
        _ = stack.createMode(name: "Default 1", isDefault: true)
        _ = stack.createMode(name: "Default 2", isDefault: true)

        try stack.save()

        let fetched = try await repo.fetchDefault()

        // Should return one of them, not crash
        #expect(fetched != nil)
    }
}
