import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("FocusModeRepository Tests")
struct FocusModeRepositoryTests {

    // MARK: - Create Tests

    @Test("Create focus mode saves to context")
    func createFocusMode() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let mode = stack.createFocusMode(name: "Deep Work")

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "Deep Work")
    }

    @Test("Create focus mode with time range")
    func createFocusMode_withTimeRange() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let now = Date()
        let mode = stack.createFocusMode(
            name: "Morning Focus",
            startTime: now.addingTimeInterval(-3600),
            endTime: now.addingTimeInterval(3600)
        )

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched?.startTime != nil)
        #expect(fetched?.endTime != nil)
    }

    // MARK: - Fetch Active Tests

    @Test("Fetch active returns active modes only")
    func fetchActive_returnsActiveOnly() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let active = stack.createFocusMode(name: "Active")
        active.isActive = true
        let inactive = stack.createFocusMode(name: "Inactive")
        inactive.isActive = false

        try stack.save()

        let modes = try await repo.fetchActive()

        #expect(modes.count == 1)
        #expect(modes.first?.name == "Active")
    }

    @Test("Fetch active returns empty when none active")
    func fetchActive_noneActive_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let inactive = stack.createFocusMode(name: "Inactive")
        inactive.isActive = false

        try stack.save()

        let modes = try await repo.fetchActive()

        #expect(modes.isEmpty)
    }

    @Test("Fetch active returns multiple active modes")
    func fetchActive_multipleActive() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        _ = stack.createFocusMode(name: "Mode 1")
        _ = stack.createFocusMode(name: "Mode 2")
        _ = stack.createFocusMode(name: "Mode 3")

        try stack.save()

        let modes = try await repo.fetchActive()

        #expect(modes.count == 3)
    }

    // MARK: - Fetch Automatic Tests

    @Test("Fetch automatic returns auto-triggered modes")
    func fetchAutomatic_returnsAutoModes() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let auto = stack.createFocusMode(name: "Auto Mode")
        auto.isAutomatic = true
        auto.isActive = true

        let manual = stack.createFocusMode(name: "Manual Mode")
        manual.isAutomatic = false
        manual.isActive = true

        try stack.save()

        let modes = try await repo.fetchAutomatic()

        #expect(modes.count == 1)
        #expect(modes.first?.name == "Auto Mode")
    }

    @Test("Fetch automatic excludes inactive automatic modes")
    func fetchAutomatic_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let activeAuto = stack.createFocusMode(name: "Active Auto")
        activeAuto.isAutomatic = true
        activeAuto.isActive = true

        let inactiveAuto = stack.createFocusMode(name: "Inactive Auto")
        inactiveAuto.isAutomatic = true
        inactiveAuto.isActive = false

        try stack.save()

        let modes = try await repo.fetchAutomatic()

        #expect(modes.count == 1)
        #expect(modes.first?.name == "Active Auto")
    }

    @Test("Fetch automatic returns empty when no automatic modes")
    func fetchAutomatic_noAutomatic_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let manual = stack.createFocusMode(name: "Manual")
        manual.isAutomatic = false

        try stack.save()

        let modes = try await repo.fetchAutomatic()

        #expect(modes.isEmpty)
    }

    // MARK: - Fetch Currently Active Tests

    @Test("Fetch currently active returns nil when no automatic modes")
    func fetchCurrentlyActive_noAutomatic_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let manual = stack.createFocusMode(name: "Manual Mode")
        manual.isAutomatic = false
        manual.isActive = true

        try stack.save()

        let active = try await repo.fetchCurrentlyActive()

        #expect(active == nil)
    }

    @Test("Fetch currently active returns nil when mode not scheduled today")
    func fetchCurrentlyActive_notScheduledToday_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let today = Calendar.current.component(.weekday, from: Date())
        let otherDay = today == 7 ? 1 : today + 1

        let mode = stack.createFocusMode(name: "Other Day Mode")
        mode.isAutomatic = true
        mode.isActive = true
        mode.daysOfWeek = [otherDay]

        try stack.save()

        let active = try await repo.fetchCurrentlyActive()

        #expect(active == nil)
    }

    @Test("Fetch currently active returns nil when outside time range")
    func fetchCurrentlyActive_outsideTimeRange_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let today = Calendar.current.component(.weekday, from: Date())

        // Mode that was active 2 hours ago
        let mode = stack.createFocusMode(
            name: "Past Mode",
            startTime: Date().addingTimeInterval(-7200), // 2 hours ago
            endTime: Date().addingTimeInterval(-3600)     // 1 hour ago
        )
        mode.isAutomatic = true
        mode.isActive = true
        mode.daysOfWeek = [today]

        try stack.save()

        let active = try await repo.fetchCurrentlyActive()

        #expect(active == nil)
    }

    // MARK: - Delete Tests

    @Test("Delete focus mode removes from context")
    func deleteFocusMode() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let mode = stack.createFocusMode(name: "To Delete")
        let modeId = mode.id!

        try stack.save()

        try await repo.delete(mode)

        let fetched = try await repo.fetchById(modeId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct focus mode")
    func fetchById_returnsFocusMode() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let mode = stack.createFocusMode(name: "Find Me")
        let modeId = mode.id!

        try stack.save()

        let fetched = try await repo.fetchById(modeId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchActive_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let modes = try await repo.fetchActive()

        #expect(modes.isEmpty)
    }

    @Test("Focus mode with filter tags")
    func focusModeWithFilterTags() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let mode = stack.createFocusMode(name: "Work Focus")
        mode.filterTagsArray = ["work", "important"]

        try stack.save()

        let fetched = try await repo.fetchById(mode.id!)
        #expect(fetched?.filterTagsArray.count == 2)
    }

    @Test("Focus mode sorted by sort order")
    func fetchActive_sortedBySortOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = FocusModeRepository(context: stack.context)

        let mode1 = stack.createFocusMode(name: "Mode A")
        mode1.sortOrder = 2

        let mode2 = stack.createFocusMode(name: "Mode B")
        mode2.sortOrder = 0

        let mode3 = stack.createFocusMode(name: "Mode C")
        mode3.sortOrder = 1

        try stack.save()

        let modes = try await repo.fetchActive()

        #expect(modes[0].name == "Mode B")
        #expect(modes[1].name == "Mode C")
        #expect(modes[2].name == "Mode A")
    }
}
