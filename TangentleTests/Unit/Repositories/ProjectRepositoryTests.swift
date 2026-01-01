import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("ProjectRepository Tests")
struct ProjectRepositoryTests {

    // MARK: - Create Tests

    @Test("Create project saves to context")
    func createProject() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = repo.create()
        project.id = UUID()
        project.name = "New Project"
        project.isActive = true
        project.sortOrder = 0
        project.createdAt = Date()
        project.updatedAt = Date()

        try await repo.save()

        let fetched = try await repo.fetchById(project.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "New Project")
    }

    @Test("Create project with emoji")
    func createProject_withEmoji() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "Work Project", emoji: "💼")
        try stack.save()

        let fetched = try await repo.fetchById(project.id!)
        #expect(fetched?.emoji == "💼")
    }

    // MARK: - Fetch Active Tests

    @Test("Fetch active returns only active projects")
    func fetchActive_returnsOnlyActive() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let active = stack.createProject(name: "Active")
        active.isActive = true
        let archived = stack.createProject(name: "Archived")
        archived.isActive = false

        try stack.save()

        let projects = try await repo.fetchActive()

        #expect(projects.count == 1)
        #expect(projects.first?.name == "Active")
    }

    @Test("Fetch active returns empty when all archived")
    func fetchActive_allArchived_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "Archived")
        project.isActive = false

        try stack.save()

        let projects = try await repo.fetchActive()

        #expect(projects.isEmpty)
    }

    @Test("Fetch active returns multiple active projects")
    func fetchActive_multipleActive() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        _ = stack.createProject(name: "Project 1")
        _ = stack.createProject(name: "Project 2")
        _ = stack.createProject(name: "Project 3")

        try stack.save()

        let projects = try await repo.fetchActive()

        #expect(projects.count == 3)
    }

    // MARK: - Fetch Archived Tests

    @Test("Fetch archived returns only archived projects")
    func fetchArchived_returnsOnlyArchived() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let archived = stack.createProject(name: "Archived")
        archived.isActive = false
        let active = stack.createProject(name: "Active")
        active.isActive = true

        try stack.save()

        let projects = try await repo.fetchArchived()

        #expect(projects.count == 1)
        #expect(projects.first?.name == "Archived")
    }

    @Test("Fetch archived returns empty when none archived")
    func fetchArchived_noneArchived_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        _ = stack.createProject(name: "Active")

        try stack.save()

        let projects = try await repo.fetchArchived()

        #expect(projects.isEmpty)
    }

    // MARK: - Fetch by Goal Tests

    @Test("Fetch by goal returns projects for specific goal")
    func fetchByGoal_returnsProjects() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let goal = stack.createGoal(name: "My Goal")
        let project1 = stack.createProject(name: "Goal Project 1")
        project1.goal = goal
        let project2 = stack.createProject(name: "Goal Project 2")
        project2.goal = goal
        _ = stack.createProject(name: "No Goal")

        try stack.save()

        let projects = try await repo.fetchByGoal(goal)

        #expect(projects.count == 2)
        #expect(projects.allSatisfy { $0.goal == goal })
    }

    @Test("Fetch by goal with no projects returns empty")
    func fetchByGoal_noProjects_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let goal = stack.createGoal(name: "Empty Goal")
        _ = stack.createProject(name: "Other Project")

        try stack.save()

        let projects = try await repo.fetchByGoal(goal)

        #expect(projects.isEmpty)
    }

    // MARK: - Delete Tests

    @Test("Delete project removes from context")
    func deleteProject() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "To Delete")
        let projectId = project.id!

        try stack.save()

        try await repo.delete(project)

        let fetched = try await repo.fetchById(projectId)
        #expect(fetched == nil)
    }

    @Test("Delete project nullifies task relationships")
    func deleteProject_tasksRemain() async throws {
        let stack = TestCoreDataStack()
        let projectRepo = ProjectRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let project = stack.createProject(name: "Project")
        let task = stack.createTask(title: "Task")
        task.project = project

        try stack.save()

        let taskId = task.id!

        try await projectRepo.delete(project)

        let fetchedTask = try await taskRepo.fetchById(taskId)
        #expect(fetchedTask != nil)
        #expect(fetchedTask?.project == nil) // Relationship nullified
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct project")
    func fetchById_returnsProject() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "Find Me")
        let projectId = project.id!

        try stack.save()

        let fetched = try await repo.fetchById(projectId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchActive_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let projects = try await repo.fetchActive()

        #expect(projects.isEmpty)
    }

    @Test("Project with special characters in name")
    func createProject_specialCharacters() async throws {
        let stack = TestCoreDataStack()
        let repo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "Project with 'quotes' & special <chars>")

        try stack.save()

        let fetched = try await repo.fetchById(project.id!)
        #expect(fetched?.name == "Project with 'quotes' & special <chars>")
    }
}
