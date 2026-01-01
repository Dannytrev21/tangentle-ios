import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for SwipeableRow and SwipeActionButton components.
final class SwipeActionSnapshotTests: SnapshotTestCase {

    // MARK: - SwipeActionButton Tests

    func testSwipeActionButton_complete_light() {
        let action = StandardSwipeActions.complete {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_complete_active_light() {
        let action = StandardSwipeActions.complete {}
        let view = SwipeActionButton(action: action, isActive: true, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_delete_light() {
        let action = StandardSwipeActions.delete {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_delete_active_light() {
        let action = StandardSwipeActions.delete {}
        let view = SwipeActionButton(action: action, isActive: true, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_defer_light() {
        let action = StandardSwipeActions.defer_ {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_edit_light() {
        let action = StandardSwipeActions.edit {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_unblock_light() {
        let action = StandardSwipeActions.unblock {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_duplicate_light() {
        let action = StandardSwipeActions.duplicate {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotLight(view, size: Sizes.swipeActionButton)
    }

    // MARK: - SwipeActionButton Dark Mode

    func testSwipeActionButton_complete_dark() {
        let action = StandardSwipeActions.complete {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotDark(view, size: Sizes.swipeActionButton)
    }

    func testSwipeActionButton_delete_dark() {
        let action = StandardSwipeActions.delete {}
        let view = SwipeActionButton(action: action, isActive: false, width: 80)
        snapshotDark(view, size: Sizes.swipeActionButton)
    }

    // MARK: - SwipeableRow Tests

    func testSwipeableRow_default_light() {
        let view = SwipeableRow(
            leadingActions: [],
            trailingActions: []
        ) {
            HStack {
                Text("Swipeable Row Content")
                    .padding()
                Spacer()
            }
            .frame(height: 60)
        }
        snapshotLight(view, size: Sizes.swipeableRow)
    }

    func testSwipeableRow_default_dark() {
        let view = SwipeableRow(
            leadingActions: [],
            trailingActions: []
        ) {
            HStack {
                Text("Swipeable Row Content")
                    .padding()
                Spacer()
            }
            .frame(height: 60)
        }
        snapshotDark(view, size: Sizes.swipeableRow)
    }

    // Note: Testing swipe states (offset positions) would require additional
    // state management in tests. The component appearance at rest position
    // is what we test here.
}
