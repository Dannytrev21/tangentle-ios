import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for AnimatedCheckbox and CompletionIndicator components.
final class CheckboxSnapshotTests: SnapshotTestCase {

    // MARK: - AnimatedCheckbox Tests

    func testAnimatedCheckbox_unchecked_priorityHigh_light() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .high, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_unchecked_priorityHigh_dark() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .high, onComplete: {})
        snapshotDark(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_checked_priorityHigh_light() {
        let view = AnimatedCheckbox(isCompleted: .constant(true), priority: .high, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_checked_priorityHigh_dark() {
        let view = AnimatedCheckbox(isCompleted: .constant(true), priority: .high, onComplete: {})
        snapshotDark(view, size: Sizes.checkbox)
    }

    // MARK: - Priority Variants

    func testAnimatedCheckbox_priorityNone_unchecked() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .none, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_priorityLow_unchecked() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .low, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_priorityMedium_unchecked() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .medium, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    func testAnimatedCheckbox_priorityMediumHigh_unchecked() {
        let view = AnimatedCheckbox(isCompleted: .constant(false), priority: .mediumHigh, onComplete: {})
        snapshotLight(view, size: Sizes.checkbox)
    }

    // MARK: - CompletionIndicator Tests

    func testCompletionIndicator_unchecked_priorityHigh_light() {
        let view = CompletionIndicator(isCompleted: false, priority: .high)
        snapshotLight(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_unchecked_priorityHigh_dark() {
        let view = CompletionIndicator(isCompleted: false, priority: .high)
        snapshotDark(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_checked_light() {
        let view = CompletionIndicator(isCompleted: true, priority: .high)
        snapshotLight(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_checked_dark() {
        let view = CompletionIndicator(isCompleted: true, priority: .high)
        snapshotDark(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_priorityNone() {
        let view = CompletionIndicator(isCompleted: false, priority: .none)
        snapshotLight(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_priorityLow() {
        let view = CompletionIndicator(isCompleted: false, priority: .low)
        snapshotLight(view, size: Sizes.completionIndicator)
    }

    func testCompletionIndicator_priorityMedium() {
        let view = CompletionIndicator(isCompleted: false, priority: .medium)
        snapshotLight(view, size: Sizes.completionIndicator)
    }
}
