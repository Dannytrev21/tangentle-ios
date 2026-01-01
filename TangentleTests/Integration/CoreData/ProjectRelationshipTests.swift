import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("Project Relationship Integration Tests")
struct ProjectRelationshipTests {

    // MARK: - Project-Goal Relationships

    @Test("Assigning goal updates bidirectional relationship")
    func projectGoal_assigningGoal_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "My Goal")
        let project = stack.createProject(name: "My Project")
        project.goal = goal
        try stack.save()

        #expect(project.goal == goal)
        #expect(goal.projects?.contains(project) == true)
    }

    @Test("Goal with multiple projects contains all")
    func goal_withMultipleProjects_containsAll() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "Goal")
        let project1 = stack.createProject(name: "Project 1")
        let project2 = stack.createProject(name: "Project 2")
        project1.goal = goal
        project2.goal = goal
        try stack.save()

        #expect(goal.projects?.count == 2)
    }

    @Test("Removing goal clears relationship")
    func projectGoal_removingGoal_clearsRelationship() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "Goal")
        let project = stack.createProject(name: "Project")
        project.goal = goal
        try stack.save()

        project.goal = nil
        try stack.save()

        #expect(project.goal == nil)
        #expect(goal.projects?.contains(project) != true)
    }

    @Test("Moving project between goals updates both")
    func projectGoal_movingBetweenGoals_updatesRelationships() async throws {
        let stack = TestCoreDataStack()

        let goalA = stack.createGoal(name: "Goal A")
        let goalB = stack.createGoal(name: "Goal B")
        let project = stack.createProject(name: "Project")
        project.goal = goalA
        try stack.save()

        #expect(goalA.projects?.contains(project) == true)
        #expect(goalB.projects?.contains(project) != true)

        project.goal = goalB
        try stack.save()

        #expect(goalA.projects?.contains(project) != true)
        #expect(goalB.projects?.contains(project) == true)
    }

    // MARK: - Project-Task Relationships

    @Test("Project tasks accessible via relationship")
    func projectTasks_accessible() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "Project")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        task1.project = project
        task2.project = project
        try stack.save()

        let tasks = project.tasks?.allObjects as? [TGTask] ?? []
        #expect(tasks.count == 2)
        #expect(tasks.contains { $0.title == "Task 1" })
        #expect(tasks.contains { $0.title == "Task 2" })
    }

    @Test("Project with tasks and goal forms complete hierarchy")
    func project_withTasksAndGoal_formsHierarchy() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "Ship v1.0")
        let project = stack.createProject(name: "Authentication")
        project.goal = goal
        let task = stack.createTask(title: "Implement login")
        task.project = project
        try stack.save()

        // Verify full chain
        #expect(task.project?.goal == goal)
        #expect(goal.projects?.contains(project) == true)
        #expect(project.tasks?.contains(task) == true)
    }

    // MARK: - Project-FocusMode Relationships

    @Test("Project can be included in focus mode")
    func projectFocusMode_inclusion_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let focusMode = stack.createFocusMode(name: "Work Mode")
        let project = stack.createProject(name: "Work Project")
        focusMode.addToIncludedProjects(project)
        try stack.save()

        #expect(focusMode.includedProjects?.contains(project) == true)
        #expect(project.focusModes?.contains(focusMode) == true)
    }

    @Test("Multiple projects in single focus mode")
    func focusMode_withMultipleProjects_containsAll() async throws {
        let stack = TestCoreDataStack()

        let focusMode = stack.createFocusMode(name: "Work Mode")
        let project1 = stack.createProject(name: "Project 1")
        let project2 = stack.createProject(name: "Project 2")
        focusMode.addToIncludedProjects(project1)
        focusMode.addToIncludedProjects(project2)
        try stack.save()

        #expect(focusMode.includedProjects?.count == 2)
    }

    @Test("Project in multiple focus modes")
    func project_inMultipleFocusModes_trackedCorrectly() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "Project")
        let focusMode1 = stack.createFocusMode(name: "Morning")
        let focusMode2 = stack.createFocusMode(name: "Afternoon")
        focusMode1.addToIncludedProjects(project)
        focusMode2.addToIncludedProjects(project)
        try stack.save()

        #expect(project.focusModes?.count == 2)
    }
}
