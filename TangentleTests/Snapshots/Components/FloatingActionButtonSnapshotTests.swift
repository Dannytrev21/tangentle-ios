import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for FloatingActionButton component.
final class FloatingActionButtonSnapshotTests: SnapshotTestCase {

    // MARK: - Default State

    func testFloatingActionButton_default_light() {
        let view = FloatingActionButton(action: {})
        snapshotLight(view, size: Sizes.floatingButton)
    }

    func testFloatingActionButton_default_dark() {
        let view = FloatingActionButton(action: {})
        snapshotDark(view, size: Sizes.floatingButton)
    }

    // MARK: - Custom Icon

    func testFloatingActionButton_checkmarkIcon_light() {
        let view = FloatingActionButton(icon: "checkmark", action: {})
        snapshotLight(view, size: Sizes.floatingButton)
    }

    func testFloatingActionButton_pencilIcon_light() {
        let view = FloatingActionButton(icon: "pencil", action: {})
        snapshotLight(view, size: Sizes.floatingButton)
    }

    func testFloatingActionButton_trashIcon_light() {
        let view = FloatingActionButton(icon: "trash", action: {})
        snapshotLight(view, size: Sizes.floatingButton)
    }

    func testFloatingActionButton_starIcon_dark() {
        let view = FloatingActionButton(icon: "star.fill", action: {})
        snapshotDark(view, size: Sizes.floatingButton)
    }
}
