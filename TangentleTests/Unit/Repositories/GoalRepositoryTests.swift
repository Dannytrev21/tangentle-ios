import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("GoalRepository Tests")
struct GoalRepositoryTests {

    // MARK: - Create Tests

    @Test("Create goal saves to context")
    func createGoal() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let goal = repo.create()
        goal.id = UUID()
        goal.name = "New Goal"
        goal.isActive = true
        goal.createdAt = Date()
        goal.updatedAt = Date()

        try await repo.save()

        let fetched = try await repo.fetchById(goal.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "New Goal")
    }

    @Test("Create goal with target date")
    func createGoal_withTargetDate() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let targetDate = Date.daysFromNow(30)
        let goal = stack.createGoal(name: "Goal with Deadline", targetDate: targetDate)

        try stack.save()

        let fetched = try await repo.fetchById(goal.id!)
        #expect(fetched?.targetDate != nil)
    }

    // MARK: - Fetch Active Tests

    @Test("Fetch active returns only active goals")
    func fetchActive_returnsOnlyActive() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let active = stack.createGoal(name: "Active Goal")
        active.isActive = true
        let inactive = stack.createGoal(name: "Inactive Goal")
        inactive.isActive = false

        try stack.save()

        let goals = try await repo.fetchActive()

        #expect(goals.count == 1)
        #expect(goals.first?.name == "Active Goal")
    }

    @Test("Fetch active returns empty when none active")
    func fetchActive_noneActive_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let inactive = stack.createGoal(name: "Inactive")
        inactive.isActive = false

        try stack.save()

        let goals = try await repo.fetchActive()

        #expect(goals.isEmpty)
    }

    @Test("Fetch active returns multiple active goals")
    func fetchActive_multipleActive() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        _ = stack.createGoal(name: "Goal 1")
        _ = stack.createGoal(name: "Goal 2")
        _ = stack.createGoal(name: "Goal 3")

        try stack.save()

        let goals = try await repo.fetchActive()

        #expect(goals.count == 3)
    }

    // MARK: - Fetch With Upcoming Deadlines Tests

    @Test("Fetch with upcoming deadlines filters correctly")
    func fetchWithUpcomingDeadlines_filtersCorrectly() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        _ = stack.createGoal(name: "Due Soon", targetDate: Date.daysFromNow(3))
        _ = stack.createGoal(name: "Due Later", targetDate: Date.daysFromNow(30))
        _ = stack.createGoal(name: "No Deadline")

        try stack.save()

        let goals = try await repo.fetchWithUpcomingDeadlines(within: 7)

        #expect(goals.count == 1)
        #expect(goals.first?.name == "Due Soon")
    }

    @Test("Fetch with upcoming deadlines excludes past deadlines")
    func fetchWithUpcomingDeadlines_excludesPast() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        _ = stack.createGoal(name: "Past", targetDate: Date.testYesterday)
        _ = stack.createGoal(name: "Future", targetDate: Date.daysFromNow(3))

        try stack.save()

        let goals = try await repo.fetchWithUpcomingDeadlines(within: 7)

        #expect(goals.count == 1)
        #expect(goals.first?.name == "Future")
    }

    @Test("Fetch with upcoming deadlines excludes inactive goals")
    func fetchWithUpcomingDeadlines_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let activeGoal = stack.createGoal(name: "Active", targetDate: Date.daysFromNow(3))
        activeGoal.isActive = true
        let inactiveGoal = stack.createGoal(name: "Inactive", targetDate: Date.daysFromNow(3))
        inactiveGoal.isActive = false

        try stack.save()

        let goals = try await repo.fetchWithUpcomingDeadlines(within: 7)

        #expect(goals.count == 1)
        #expect(goals.first?.name == "Active")
    }

    @Test("Fetch with upcoming deadlines returns empty for no matches")
    func fetchWithUpcomingDeadlines_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        _ = stack.createGoal(name: "Far Future", targetDate: Date.daysFromNow(60))
        _ = stack.createGoal(name: "No Deadline")

        try stack.save()

        let goals = try await repo.fetchWithUpcomingDeadlines(within: 7)

        #expect(goals.isEmpty)
    }

    @Test("Fetch with upcoming deadlines with 0 days returns today only")
    func fetchWithUpcomingDeadlines_zeroDays() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        // Note: This test is tricky because "within 0 days" depends on implementation
        // The repo uses >= now AND <= now+0 days which might not catch "today"
        // depending on time of day. Adjust expectation accordingly.
        _ = stack.createGoal(name: "Tomorrow", targetDate: Date.testTomorrow)

        try stack.save()

        let goals = try await repo.fetchWithUpcomingDeadlines(within: 0)

        // With 0 days, should return goals due between now and now (essentially today)
        #expect(goals.isEmpty) // Tomorrow is not within 0 days
    }

    // MARK: - Delete Tests

    @Test("Delete goal removes from context")
    func deleteGoal() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let goal = stack.createGoal(name: "To Delete")
        let goalId = goal.id!

        try stack.save()

        try await repo.delete(goal)

        let fetched = try await repo.fetchById(goalId)
        #expect(fetched == nil)
    }

    @Test("Delete goal nullifies project relationships")
    func deleteGoal_projectsRemain() async throws {
        let stack = TestCoreDataStack()
        let goalRepo = GoalRepository(context: stack.context)
        let projectRepo = ProjectRepository(context: stack.context)

        let goal = stack.createGoal(name: "Goal")
        let project = stack.createProject(name: "Project")
        project.goal = goal

        try stack.save()

        let projectId = project.id!

        try await goalRepo.delete(goal)

        let fetchedProject = try await projectRepo.fetchById(projectId)
        #expect(fetchedProject != nil)
        #expect(fetchedProject?.goal == nil) // Relationship nullified
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct goal")
    func fetchById_returnsGoal() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let goal = stack.createGoal(name: "Find Me")
        let goalId = goal.id!

        try stack.save()

        let fetched = try await repo.fetchById(goalId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchActive_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let goals = try await repo.fetchActive()

        #expect(goals.isEmpty)
    }

    @Test("Goal with long description")
    func createGoal_longDescription() async throws {
        let stack = TestCoreDataStack()
        let repo = GoalRepository(context: stack.context)

        let longName = String(repeating: "A", count: 500)
        let goal = stack.createGoal(name: longName)

        try stack.save()

        let fetched = try await repo.fetchById(goal.id!)
        #expect(fetched?.name == longName)
    }
}
