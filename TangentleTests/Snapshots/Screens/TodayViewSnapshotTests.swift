import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for Today view components:
/// TodayHeader, TaskSection, TodayEmptyState.
/// Note: Full TodayView requires container/viewmodel setup which is complex.
/// We test the constituent components instead.
final class TodayViewSnapshotTests: SnapshotTestCase {

    // MARK: - TodayHeader Tests

    func testTodayHeader_light() {
        let view = TodayHeader()
            .padding()
        snapshotLight(view, size: CGSize(width: 360, height: 80))
    }

    func testTodayHeader_dark() {
        let view = TodayHeader()
            .padding()
        snapshotDark(view, size: CGSize(width: 360, height: 80))
    }

    // MARK: - TaskSection Tests

    func testTaskSection_overdue_light() {
        let view = TaskSection(
            title: "Overdue",
            icon: "exclamationmark.triangle.fill",
            iconColor: WarmLightTheme().statusError,
            count: 2
        ) {
            Text("Task items placeholder")
                .padding()
                .frame(maxWidth: .infinity)
                .background(WarmLightTheme().surfaceElevated)
                .cornerRadius(CornerRadius.md)
        }
        snapshotLight(view, size: CGSize(width: 360, height: 100))
    }

    func testTaskSection_overdue_dark() {
        let view = TaskSection(
            title: "Overdue",
            icon: "exclamationmark.triangle.fill",
            iconColor: WarmDarkTheme().statusError,
            count: 2
        ) {
            Text("Task items placeholder")
                .padding()
                .frame(maxWidth: .infinity)
                .background(WarmDarkTheme().surfaceElevated)
                .cornerRadius(CornerRadius.md)
        }
        snapshotDark(view, size: CGSize(width: 360, height: 100))
    }

    func testTaskSection_today_light() {
        let view = TaskSection(
            title: "Today",
            icon: "calendar",
            iconColor: WarmLightTheme().accentPrimary,
            count: 5
        ) {
            Text("Task items placeholder")
                .padding()
                .frame(maxWidth: .infinity)
                .background(WarmLightTheme().surfaceElevated)
                .cornerRadius(CornerRadius.md)
        }
        snapshotLight(view, size: CGSize(width: 360, height: 100))
    }

    func testTaskSection_emptyCount() {
        let view = TaskSection(
            title: "Today",
            icon: "calendar",
            iconColor: WarmLightTheme().accentPrimary,
            count: 0
        ) {
            Text("No tasks")
                .foregroundStyle(WarmLightTheme().textSecondary)
                .padding()
        }
        snapshotLight(view, size: CGSize(width: 360, height: 100))
    }

    // MARK: - TodayEmptyState Tests

    func testTodayEmptyState_light() {
        let view = TodayEmptyState()
        snapshotLight(view, size: CGSize(width: 360, height: 250))
    }

    func testTodayEmptyState_dark() {
        let view = TodayEmptyState()
        snapshotDark(view, size: CGSize(width: 360, height: 250))
    }

    // MARK: - TaskRow (Combined Components) Tests

    func testTaskRowWithCard_light() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Sample task", priority: .medium)
        task.estimatedDuration = 30

        let view = SwipeableRow(
            leadingActions: [StandardSwipeActions.complete {}],
            trailingActions: [
                StandardSwipeActions.defer_ {},
                StandardSwipeActions.delete {}
            ]
        ) {
            TaskCard(task: task, onTap: {})
        }
        snapshotLight(view, size: Sizes.taskCard)
    }

    func testTaskRowWithCard_dark() {
        let stack = makeTestContext()
        let task = stack.createTask(title: "Sample task", priority: .high)
        task.estimatedDuration = 45

        let view = SwipeableRow(
            leadingActions: [StandardSwipeActions.complete {}],
            trailingActions: [
                StandardSwipeActions.defer_ {},
                StandardSwipeActions.delete {}
            ]
        ) {
            TaskCard(task: task, onTap: {})
        }
        snapshotDark(view, size: Sizes.taskCard)
    }

    // MARK: - Device Size Tests

    func testTodayEmptyState_iPhoneSE() {
        let view = TodayEmptyState()
        snapshotLight(view, size: CGSize(width: 375, height: 250))
    }

    func testTodayEmptyState_iPhone15ProMax() {
        let view = TodayEmptyState()
        snapshotLight(view, size: CGSize(width: 430, height: 280))
    }
}
