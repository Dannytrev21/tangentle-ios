import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TagRepository Tests")
struct TagRepositoryTests {

    // MARK: - Create Tests

    @Test("Create tag saves to context")
    func createTag() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tag = stack.createTag(name: "Important")

        try stack.save()

        let fetched = try await repo.fetchById(tag.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Important")
    }

    @Test("Create tag with sort order")
    func createTag_withSortOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tag = stack.createTag(name: "Priority")
        tag.sortOrder = 5

        try stack.save()

        let fetched = try await repo.fetchById(tag.id!)
        #expect(fetched?.sortOrder == 5)
    }

    // MARK: - Fetch All Tests

    @Test("Fetch all returns all tags")
    func fetchAll_returnsAll() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Work")
        _ = stack.createTag(name: "Personal")
        _ = stack.createTag(name: "Urgent")

        try stack.save()

        let tags = try await repo.fetchAll()

        #expect(tags.count == 3)
    }

    @Test("Fetch all returns empty when no tags")
    func fetchAll_noTags_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tags = try await repo.fetchAll()

        #expect(tags.isEmpty)
    }

    @Test("Fetch all sorts by name")
    func fetchAll_sortsByName() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Zebra")
        _ = stack.createTag(name: "Alpha")
        _ = stack.createTag(name: "Beta")

        try stack.save()

        let tags = try await repo.fetchAll()

        #expect(tags[0].name == "Alpha")
        #expect(tags[1].name == "Beta")
        #expect(tags[2].name == "Zebra")
    }

    // MARK: - Fetch Or Create Tests

    @Test("Fetch or create returns existing tag if name matches")
    func fetchOrCreate_existingTag_returnsExisting() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let existing = stack.createTag(name: "Work")

        try stack.save()

        let fetched = try await repo.fetchOrCreate(name: "Work")

        #expect(fetched.id == existing.id)
    }

    @Test("Fetch or create creates new tag if name doesn't exist")
    func fetchOrCreate_newTag_createsNew() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Existing")

        try stack.save()

        let created = try await repo.fetchOrCreate(name: "New Tag")

        #expect(created.name == "New Tag")

        let allTags = try await repo.fetchAll()
        #expect(allTags.count == 2)
    }

    @Test("Fetch or create is case insensitive")
    func fetchOrCreate_caseInsensitive() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let existing = stack.createTag(name: "Work")

        try stack.save()

        let fetched = try await repo.fetchOrCreate(name: "work")

        #expect(fetched.id == existing.id)
    }

    @Test("Fetch or create with empty database creates tag")
    func fetchOrCreate_emptyDatabase_createsTag() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let created = try await repo.fetchOrCreate(name: "First Tag")

        #expect(created.name == "First Tag")
        #expect(created.id != nil)
    }

    // MARK: - Fetch By Name Tests

    @Test("Fetch by name finds tag")
    func fetchByName_findsTag() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Important")

        try stack.save()

        let found = try await repo.fetchByName("Important")

        #expect(found != nil)
        #expect(found?.name == "Important")
    }

    @Test("Fetch by name returns nil for unknown name")
    func fetchByName_unknown_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Existing")

        try stack.save()

        let found = try await repo.fetchByName("NonExistent")

        #expect(found == nil)
    }

    @Test("Fetch by name is case insensitive")
    func fetchByName_caseInsensitive() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        _ = stack.createTag(name: "Important")

        try stack.save()

        let foundLower = try await repo.fetchByName("important")
        let foundUpper = try await repo.fetchByName("IMPORTANT")

        #expect(foundLower != nil)
        #expect(foundUpper != nil)
        #expect(foundLower?.id == foundUpper?.id)
    }

    @Test("Fetch by name with empty database returns nil")
    func fetchByName_emptyDatabase_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let found = try await repo.fetchByName("AnyTag")

        #expect(found == nil)
    }

    // MARK: - Delete Tests

    @Test("Delete tag removes from context")
    func deleteTag() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tag = stack.createTag(name: "To Delete")
        let tagId = tag.id!

        try stack.save()

        try await repo.delete(tag)

        let fetched = try await repo.fetchById(tagId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct tag")
    func fetchById_returnsTag() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tag = stack.createTag(name: "Find Me")
        let tagId = tag.id!

        try stack.save()

        let fetched = try await repo.fetchById(tagId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchAll_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let tags = try await repo.fetchAll()

        #expect(tags.isEmpty)
    }

    @Test("Very long tag name")
    func createTag_veryLongName() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let longName = String(repeating: "A", count: 500)
        let tag = stack.createTag(name: longName)

        try stack.save()

        let fetched = try await repo.fetchById(tag.id!)
        #expect(fetched?.name == longName)
    }

    @Test("Tag with special characters")
    func createTag_specialCharacters() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let specialName = "Test @#$%^&* Tag!"
        let tag = stack.createTag(name: specialName)

        try stack.save()

        let fetched = try await repo.fetchByName(specialName)
        #expect(fetched != nil)
        #expect(fetched?.name == specialName)
    }

    @Test("Tag with emoji")
    func createTag_emoji() async throws {
        let stack = TestCoreDataStack()
        let repo = TagRepository(context: stack.context)

        let emojiName = "Important 🔥"
        let tag = stack.createTag(name: emojiName)

        try stack.save()

        let fetched = try await repo.fetchByName(emojiName)
        #expect(fetched != nil)
        #expect(fetched?.name == emojiName)
    }
}
