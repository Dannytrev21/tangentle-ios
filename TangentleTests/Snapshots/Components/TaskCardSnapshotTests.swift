import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for TaskCard component.
final class TaskCardSnapshotTests: SnapshotTestCase {

    // MARK: - Default State Tests

    func testTaskCard_default_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Review quarterly report", priority: .medium)
        task.estimatedDuration = 30
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_default_dark() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Review quarterly report", priority: .medium)
        task.estimatedDuration = 30
        let view = TaskCard(task: task, onTap: {})
        snapshotDark(view, size: Sizes.taskCard)
    }

    // MARK: - Status Variants

    func testTaskCard_completed_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Completed task", priority: .medium, status: .done)
        task.completedAt = Date()
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_completed_dark() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Completed task", priority: .medium, status: .done)
        task.completedAt = Date()
        let view = TaskCard(task: task, onTap: {})
        snapshotDark(view, size: Sizes.taskCard)
    }

    func testTaskCard_overdue_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Overdue task", priority: .high, dueDate: .testYesterday)
        task.estimatedDuration = 45
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_overdue_dark() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Overdue task", priority: .high, dueDate: .testYesterday)
        task.estimatedDuration = 45
        let view = TaskCard(task: task, onTap: {})
        snapshotDark(view, size: Sizes.taskCard)
    }

    // MARK: - Priority Variants

    func testTaskCard_priorityHigh_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "High priority task", priority: .high)
        task.estimatedDuration = 30
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_priorityLow_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Low priority task", priority: .low)
        task.estimatedDuration = 15
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_priorityNone_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "No priority task", priority: .none)
        task.estimatedDuration = 20
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    // MARK: - With Project

    func testTaskCard_withProject_light() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Work", emoji: "💼")
        let task = stack.createTask(title: "Task with project", priority: .medium)
        task.project = project
        task.estimatedDuration = 30
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_withProject_dark() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Work", emoji: "💼")
        let task = stack.createTask(title: "Task with project", priority: .medium)
        task.project = project
        task.estimatedDuration = 30
        let view = TaskCard(task: task, onTap: {})
        snapshotDark(view, size: Sizes.taskCard)
    }

    // MARK: - Energy Variants

    func testTaskCard_energyHigh_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "High energy task", priority: .medium)
        task.energyRequired = EnergyLevel.high.rawValue
        task.estimatedDuration = 60
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskCard_energyLow_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Low energy task", priority: .low)
        task.energyRequired = EnergyLevel.low.rawValue
        task.estimatedDuration = 15
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    // MARK: - Long Title

    func testTaskCard_longTitle_light() {
        let stack = makeTestContext()
        let task = stack.createTask(
            title: "A very long task title that will likely wrap to multiple lines",
            priority: .medium
        )
        task.estimatedDuration = 45
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCardTall)
    }

    // MARK: - Minimal

    func testTaskCard_minimal_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Simple task", priority: .none)
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCard)
    }

    // MARK: - All Metadata

    func testTaskCard_allMetadata_light() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Important", emoji: "🔥")
        let task = stack.createTask(
            title: "Task with all metadata",
            priority: .high,
            dueDate: .testYesterday
        )
        task.project = project
        task.estimatedDuration = 90
        task.energyRequired = EnergyLevel.high.rawValue
        let view = TaskCard(task: task, onTap: {})
        snapshotLight(view, size: Sizes.taskCardTall)
    }
}
