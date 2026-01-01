import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("ProblemTypeRepository Tests")
struct ProblemTypeRepositoryTests {

    // MARK: - Create Tests

    @Test("Create problem type saves to context")
    func createProblemType() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let problemType = stack.createProblemType(identifier: "too_big", label: "Too Big")

        try stack.save()

        let fetched = try await repo.fetchById(problemType.id!)
        #expect(fetched != nil)
        #expect(fetched?.label == "Too Big")
    }

    @Test("Create problem type with description")
    func createProblemType_withDescription() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let problemType = stack.createProblemType(identifier: "boring", label: "Boring")
        problemType.problemTypeDescription = "Task feels tedious or uninteresting"

        try stack.save()

        let fetched = try await repo.fetchById(problemType.id!)
        #expect(fetched?.problemTypeDescription == "Task feels tedious or uninteresting")
    }

    // MARK: - Fetch All Tests

    @Test("Fetch all returns all problem types")
    func fetchAll_returnsAll() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        _ = stack.createProblemType(identifier: "too_big", label: "Too Big")
        _ = stack.createProblemType(identifier: "boring", label: "Boring")
        _ = stack.createProblemType(identifier: "unclear", label: "Unclear")

        try stack.save()

        let types = try await repo.fetchAll()

        #expect(types.count == 3)
    }

    @Test("Fetch all returns empty when no types")
    func fetchAll_noTypes_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let types = try await repo.fetchAll()

        #expect(types.isEmpty)
    }

    @Test("Fetch all sorts by sort order")
    func fetchAll_sortsBySortOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let type1 = stack.createProblemType(identifier: "third", label: "Third")
        type1.sortOrder = 2

        let type2 = stack.createProblemType(identifier: "first", label: "First")
        type2.sortOrder = 0

        let type3 = stack.createProblemType(identifier: "second", label: "Second")
        type3.sortOrder = 1

        try stack.save()

        let types = try await repo.fetchAll()

        #expect(types[0].identifier == "first")
        #expect(types[1].identifier == "second")
        #expect(types[2].identifier == "third")
    }

    // MARK: - Fetch By Identifier Tests

    @Test("Fetch by identifier finds by unique identifier")
    func fetchByIdentifier_findsMatch() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        _ = stack.createProblemType(identifier: "too_big", label: "Too Big")
        _ = stack.createProblemType(identifier: "boring", label: "Boring")

        try stack.save()

        let found = try await repo.fetchByIdentifier("too_big")

        #expect(found != nil)
        #expect(found?.label == "Too Big")
    }

    @Test("Fetch by identifier returns nil for unknown identifier")
    func fetchByIdentifier_unknown_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        _ = stack.createProblemType(identifier: "too_big", label: "Too Big")

        try stack.save()

        let found = try await repo.fetchByIdentifier("unknown_type")

        #expect(found == nil)
    }

    @Test("Fetch by identifier with empty database returns nil")
    func fetchByIdentifier_emptyDatabase_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let found = try await repo.fetchByIdentifier("any_type")

        #expect(found == nil)
    }

    // MARK: - Fetch Defaults Tests

    @Test("Fetch defaults returns built-in types")
    func fetchDefaults_returnsBuiltIn() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let defaultType = stack.createProblemType(identifier: "default_type", label: "Default")
        defaultType.isDefault = true

        let customType = stack.createProblemType(identifier: "custom_type", label: "Custom")
        customType.isDefault = false

        try stack.save()

        let defaults = try await repo.fetchDefaults()

        #expect(defaults.count == 1)
        #expect(defaults.first?.identifier == "default_type")
    }

    @Test("Fetch defaults returns empty when no defaults")
    func fetchDefaults_noDefaults_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let customType = stack.createProblemType(identifier: "custom", label: "Custom")
        customType.isDefault = false

        try stack.save()

        let defaults = try await repo.fetchDefaults()

        #expect(defaults.isEmpty)
    }

    @Test("Fetch defaults returns multiple default types")
    func fetchDefaults_multipleDefaults() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let type1 = stack.createProblemType(identifier: "too_big", label: "Too Big")
        type1.isDefault = true
        type1.sortOrder = 0

        let type2 = stack.createProblemType(identifier: "boring", label: "Boring")
        type2.isDefault = true
        type2.sortOrder = 1

        let type3 = stack.createProblemType(identifier: "custom", label: "Custom")
        type3.isDefault = false

        try stack.save()

        let defaults = try await repo.fetchDefaults()

        #expect(defaults.count == 2)
    }

    @Test("Fetch defaults sorts by sort order")
    func fetchDefaults_sortsBySortOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let type1 = stack.createProblemType(identifier: "third", label: "Third")
        type1.isDefault = true
        type1.sortOrder = 2

        let type2 = stack.createProblemType(identifier: "first", label: "First")
        type2.isDefault = true
        type2.sortOrder = 0

        let type3 = stack.createProblemType(identifier: "second", label: "Second")
        type3.isDefault = true
        type3.sortOrder = 1

        try stack.save()

        let defaults = try await repo.fetchDefaults()

        #expect(defaults[0].identifier == "first")
        #expect(defaults[1].identifier == "second")
        #expect(defaults[2].identifier == "third")
    }

    // MARK: - Delete Tests

    @Test("Delete problem type removes from context")
    func deleteProblemType() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let problemType = stack.createProblemType(identifier: "to_delete", label: "To Delete")
        let typeId = problemType.id!

        try stack.save()

        try await repo.delete(problemType)

        let fetched = try await repo.fetchById(typeId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct problem type")
    func fetchById_returnsProblemType() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let problemType = stack.createProblemType(identifier: "find_me", label: "Find Me")
        let typeId = problemType.id!

        try stack.save()

        let fetched = try await repo.fetchById(typeId)

        #expect(fetched != nil)
        #expect(fetched?.label == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchAll_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let types = try await repo.fetchAll()

        #expect(types.isEmpty)
    }

    @Test("Problem type with suggested strategies")
    func problemTypeWithSuggestedStrategies() async throws {
        let stack = TestCoreDataStack()
        let repo = ProblemTypeRepository(context: stack.context)

        let problemType = stack.createProblemType(identifier: "too_big", label: "Too Big")
        let strategyId1 = UUID()
        let strategyId2 = UUID()
        problemType.suggestedStrategyIdsArray = [strategyId1, strategyId2]

        try stack.save()

        let fetched = try await repo.fetchById(problemType.id!)
        #expect(fetched?.suggestedStrategyIdsArray.count == 2)
    }
}
