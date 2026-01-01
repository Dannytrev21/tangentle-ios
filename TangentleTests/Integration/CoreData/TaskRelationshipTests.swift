import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("Task Relationship Integration Tests")
struct TaskRelationshipTests {

    // MARK: - Task-Project Relationships

    @Test("Assigning project updates bidirectional relationship")
    func taskProject_assigningProject_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "My Project")
        let task = stack.createTask(title: "My Task")
        task.project = project
        try stack.save()

        // Verify bidirectional
        #expect(task.project == project)
        #expect(project.tasks?.contains(task) == true)
    }

    @Test("Removing project clears relationship")
    func taskProject_removingProject_clearsRelationship() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "My Project")
        let task = stack.createTask(title: "My Task")
        task.project = project
        try stack.save()

        task.project = nil
        try stack.save()

        #expect(task.project == nil)
        #expect(project.tasks?.contains(task) == false)
    }

    @Test("Project with multiple tasks contains all tasks")
    func project_withMultipleTasks_containsAllTasks() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "Project")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        let task3 = stack.createTask(title: "Task 3")

        task1.project = project
        task2.project = project
        task3.project = project
        try stack.save()

        #expect(project.tasks?.count == 3)
    }

    @Test("Project task count is accurate")
    func project_taskCount_isAccurate() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "Project")
        for i in 0..<5 {
            let task = stack.createTask(title: "Task \(i)")
            task.project = project
        }
        try stack.save()

        #expect(project.tasks?.count == 5)
    }

    @Test("Moving task between projects updates both")
    func taskProject_movingBetweenProjects_updatesRelationships() async throws {
        let stack = TestCoreDataStack()

        let projectA = stack.createProject(name: "Project A")
        let projectB = stack.createProject(name: "Project B")
        let task = stack.createTask(title: "Moving Task")
        task.project = projectA
        try stack.save()

        #expect(projectA.tasks?.contains(task) == true)
        #expect(projectB.tasks?.contains(task) != true)

        task.project = projectB
        try stack.save()

        #expect(projectA.tasks?.contains(task) != true)
        #expect(projectB.tasks?.contains(task) == true)
    }

    // MARK: - Task-Subtask Relationships

    @Test("Adding subtask updates parent relationship")
    func taskSubtask_addingSubtask_updatesParent() async throws {
        let stack = TestCoreDataStack()

        let parent = stack.createTask(title: "Parent Task")
        let subtask = stack.createTask(title: "Subtask")
        subtask.parentTask = parent
        try stack.save()

        #expect(subtask.parentTask == parent)
        #expect(parent.subtasks?.contains(subtask) == true)
    }

    @Test("Subtask can access parent")
    func taskSubtask_subtaskAccessesParent() async throws {
        let stack = TestCoreDataStack()

        let parent = stack.createTask(title: "Parent")
        let subtask = stack.createTask(title: "Subtask")
        subtask.parentTask = parent
        try stack.save()

        // Refetch to ensure persistence
        let taskRepo = TaskRepository(context: stack.context)
        let fetched = try await taskRepo.fetchById(subtask.id!)

        #expect(fetched?.parentTask?.title == "Parent")
    }

    @Test("Multiple subtasks maintain relationship")
    func taskSubtask_multipleSubtasks_maintainRelationship() async throws {
        let stack = TestCoreDataStack()

        let parent = stack.createTask(title: "Parent")
        for i in 0..<3 {
            let subtask = stack.createTask(title: "Subtask \(i)")
            subtask.parentTask = parent
            subtask.sortOrder = Int32(i)
        }
        try stack.save()

        let subtasks = parent.subtasks?.allObjects as? [TGTask] ?? []
        #expect(subtasks.count == 3)
    }

    @Test("Nested subtasks preserve hierarchy")
    func taskSubtask_nestedSubtasks_preserveHierarchy() async throws {
        let stack = TestCoreDataStack()

        let grandparent = stack.createTask(title: "Grandparent")
        let parent = stack.createTask(title: "Parent")
        let child = stack.createTask(title: "Child")

        parent.parentTask = grandparent
        child.parentTask = parent
        try stack.save()

        #expect(child.parentTask == parent)
        #expect(parent.parentTask == grandparent)
        #expect(grandparent.subtasks?.contains(parent) == true)
        #expect(parent.subtasks?.contains(child) == true)
    }

    // MARK: - Task-Goal Relationships

    @Test("Assigning goal updates relationship")
    func taskGoal_assigningGoal_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "My Goal")
        let task = stack.createTask(title: "Task")
        task.goal = goal
        try stack.save()

        #expect(task.goal == goal)
        #expect(goal.tasks?.contains(task) == true)
    }

    @Test("Goal with multiple tasks contains all")
    func goal_withMultipleTasks_containsAll() async throws {
        let stack = TestCoreDataStack()

        let goal = stack.createGoal(name: "Goal")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        task1.goal = goal
        task2.goal = goal
        try stack.save()

        #expect(goal.tasks?.count == 2)
    }

    // MARK: - Task-Strategy Relationships

    @Test("Linking strategy updates relationship")
    func taskStrategy_linkingStrategy_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let task = stack.createTask(title: "Task")
        let strategy = stack.createStrategy(name: "Strategy")
        task.addToLinkedStrategies(strategy)
        try stack.save()

        #expect(task.linkedStrategies?.contains(strategy) == true)
        #expect(strategy.linkedTasks?.contains(task) == true)
    }

    @Test("Multiple strategies can be linked to task")
    func taskStrategy_multipleStrategies_allLinked() async throws {
        let stack = TestCoreDataStack()

        let task = stack.createTask(title: "Task")
        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")
        task.addToLinkedStrategies(strategy1)
        task.addToLinkedStrategies(strategy2)
        try stack.save()

        #expect(task.linkedStrategies?.count == 2)
    }

    // MARK: - Task-Tag Relationships

    @Test("Adding tag updates relationship")
    func taskTag_addingTag_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let task = stack.createTask(title: "Task")
        let tag = stack.createTag(name: "Important")
        task.addToTags(tag)
        try stack.save()

        #expect(task.tags?.contains(tag) == true)
        #expect(tag.tasks?.contains(task) == true)
    }

    @Test("Multiple tags accessible from task")
    func taskTag_multipleTags_allAccessible() async throws {
        let stack = TestCoreDataStack()

        let task = stack.createTask(title: "Task")
        let tag1 = stack.createTag(name: "Tag 1")
        let tag2 = stack.createTag(name: "Tag 2")
        task.addToTags(tag1)
        task.addToTags(tag2)
        try stack.save()

        #expect(task.tags?.count == 2)
    }

    @Test("Tag used by multiple tasks tracked correctly")
    func tag_usedByMultipleTasks_trackedCorrectly() async throws {
        let stack = TestCoreDataStack()

        let tag = stack.createTag(name: "Shared Tag")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        task1.addToTags(tag)
        task2.addToTags(tag)
        try stack.save()

        #expect(tag.tasks?.count == 2)
    }

    @Test("Removing tag clears relationship")
    func taskTag_removingTag_clearsRelationship() async throws {
        let stack = TestCoreDataStack()

        let task = stack.createTask(title: "Task")
        let tag = stack.createTag(name: "Tag")
        task.addToTags(tag)
        try stack.save()

        task.removeFromTags(tag)
        try stack.save()

        #expect(task.tags?.contains(tag) != true)
        #expect(tag.tasks?.contains(task) != true)
    }

    // MARK: - Task-FocusMode Relationships

    @Test("Assigning focus mode updates relationship")
    func taskFocusMode_assigningMode_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let focusMode = stack.createFocusMode(name: "Deep Work")
        let task = stack.createTask(title: "Task")
        task.focusMode = focusMode
        try stack.save()

        #expect(task.focusMode == focusMode)
        #expect(focusMode.tasks?.contains(task) == true)
    }

    // MARK: - Task-Routine Relationships

    @Test("Linking routine updates relationship")
    func taskRoutine_linkingRoutine_updatesRelationship() async throws {
        let stack = TestCoreDataStack()

        let routine = stack.createRoutine(name: "Morning Routine")
        let task = stack.createTask(title: "Task")
        task.routine = routine
        try stack.save()

        #expect(task.routine == routine)
        #expect(routine.linkedTasks?.contains(task) == true)
    }

    // MARK: - Task Blocking Relationships

    @Test("Task blocking relationship is bidirectional")
    func taskBlocking_setBothDirections() async throws {
        let stack = TestCoreDataStack()

        let blocker = stack.createTask(title: "Blocker")
        let blocked = stack.createTask(title: "Blocked")
        blocked.addToBlockedBy(blocker)
        try stack.save()

        #expect(blocked.blockedBy?.contains(blocker) == true)
        #expect(blocker.blocking?.contains(blocked) == true)
    }

    @Test("Multiple blocking tasks tracked correctly")
    func taskBlocking_multipleBlockers_trackedCorrectly() async throws {
        let stack = TestCoreDataStack()

        let blocker1 = stack.createTask(title: "Blocker 1")
        let blocker2 = stack.createTask(title: "Blocker 2")
        let blocked = stack.createTask(title: "Blocked")
        blocked.addToBlockedBy(blocker1)
        blocked.addToBlockedBy(blocker2)
        try stack.save()

        #expect(blocked.blockedBy?.count == 2)
    }
}
