import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for all badge components:
/// PriorityBadge, EnergyBadge, DurationBadge, ProjectBadge,
/// BlockedBadge, OverdueBadge, InProgressBadge, WaitingBadge.
final class BadgeSnapshotTests: SnapshotTestCase {

    // MARK: - Priority Badge Tests

    func testPriorityBadge_none_light() {
        let view = PriorityBadge(priority: .none)
        snapshotLight(view, size: Sizes.badge)
    }

    func testPriorityBadge_none_dark() {
        let view = PriorityBadge(priority: .none)
        snapshotDark(view, size: Sizes.badge)
    }

    func testPriorityBadge_low_light() {
        let view = PriorityBadge(priority: .low)
        snapshotLight(view, size: Sizes.badge)
    }

    func testPriorityBadge_low_dark() {
        let view = PriorityBadge(priority: .low)
        snapshotDark(view, size: Sizes.badge)
    }

    func testPriorityBadge_medium_light() {
        let view = PriorityBadge(priority: .medium)
        snapshotLight(view, size: Sizes.badge)
    }

    func testPriorityBadge_medium_dark() {
        let view = PriorityBadge(priority: .medium)
        snapshotDark(view, size: Sizes.badge)
    }

    func testPriorityBadge_high_light() {
        let view = PriorityBadge(priority: .high)
        snapshotLight(view, size: Sizes.badge)
    }

    func testPriorityBadge_high_dark() {
        let view = PriorityBadge(priority: .high)
        snapshotDark(view, size: Sizes.badge)
    }

    // MARK: - Energy Badge Tests

    func testEnergyBadge_low_light() {
        let view = EnergyBadge(energy: .low)
        snapshotLight(view, size: Sizes.badge)
    }

    func testEnergyBadge_low_dark() {
        let view = EnergyBadge(energy: .low)
        snapshotDark(view, size: Sizes.badge)
    }

    func testEnergyBadge_medium_light() {
        let view = EnergyBadge(energy: .medium)
        snapshotLight(view, size: Sizes.badge)
    }

    func testEnergyBadge_medium_dark() {
        let view = EnergyBadge(energy: .medium)
        snapshotDark(view, size: Sizes.badge)
    }

    func testEnergyBadge_high_light() {
        let view = EnergyBadge(energy: .high)
        snapshotLight(view, size: Sizes.badge)
    }

    func testEnergyBadge_high_dark() {
        let view = EnergyBadge(energy: .high)
        snapshotDark(view, size: Sizes.badge)
    }

    // MARK: - Duration Badge Tests

    func testDurationBadge_5min() {
        let view = DurationBadge(minutes: 5)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_15min() {
        let view = DurationBadge(minutes: 15)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_30min() {
        let view = DurationBadge(minutes: 30)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_60min() {
        let view = DurationBadge(minutes: 60)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_90min() {
        let view = DurationBadge(minutes: 90)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_120min() {
        let view = DurationBadge(minutes: 120)
        snapshotLight(view, size: Sizes.badge)
    }

    func testDurationBadge_dark() {
        let view = DurationBadge(minutes: 30)
        snapshotDark(view, size: Sizes.badge)
    }

    // MARK: - Project Badge Tests

    func testProjectBadge_withEmoji_light() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Work", emoji: "💼")
        let view = ProjectBadge(project: project)
        snapshotLight(view, size: Sizes.badgeWide)
    }

    func testProjectBadge_withEmoji_dark() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Work", emoji: "💼")
        let view = ProjectBadge(project: project)
        snapshotDark(view, size: Sizes.badgeWide)
    }

    func testProjectBadge_withoutEmoji_light() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Personal", emoji: nil)
        let view = ProjectBadge(project: project)
        snapshotLight(view, size: Sizes.badgeWide)
    }

    func testProjectBadge_longName() {
        let stack = makeTestContext()
        let project = stack.createProject(name: "Very Long Project Name", emoji: "📚")
        let view = ProjectBadge(project: project)
        snapshotLight(view, size: CGSize(width: 200, height: 32))
    }

    // MARK: - Status Badge Tests

    func testBlockedBadge_light() {
        let view = BlockedBadge()
        snapshotLight(view, size: Sizes.statusBadge)
    }

    func testBlockedBadge_dark() {
        let view = BlockedBadge()
        snapshotDark(view, size: Sizes.statusBadge)
    }

    func testOverdueBadge_light() {
        let view = OverdueBadge()
        snapshotLight(view, size: Sizes.statusBadge)
    }

    func testOverdueBadge_dark() {
        let view = OverdueBadge()
        snapshotDark(view, size: Sizes.statusBadge)
    }

    func testInProgressBadge_light() {
        let view = InProgressBadge()
        snapshotLight(view, size: Sizes.statusBadge)
    }

    func testInProgressBadge_dark() {
        let view = InProgressBadge()
        snapshotDark(view, size: Sizes.statusBadge)
    }

    func testWaitingBadge_light() {
        let view = WaitingBadge()
        snapshotLight(view, size: Sizes.statusBadge)
    }

    func testWaitingBadge_dark() {
        let view = WaitingBadge()
        snapshotDark(view, size: Sizes.statusBadge)
    }
}
