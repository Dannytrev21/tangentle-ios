import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Snapshot tests for CustomTabBar and TabBarItem components.
final class TabBarSnapshotTests: SnapshotTestCase {

    // MARK: - CustomTabBar Tests

    func testCustomTabBar_todaySelected_light() {
        let view = CustomTabBar(selectedTab: .constant(.today), isVisible: true)
        snapshotLight(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_todaySelected_dark() {
        let view = CustomTabBar(selectedTab: .constant(.today), isVisible: true)
        snapshotDark(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_tasksSelected_light() {
        let view = CustomTabBar(selectedTab: .constant(.tasks), isVisible: true)
        snapshotLight(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_calendarSelected_light() {
        let view = CustomTabBar(selectedTab: .constant(.calendar), isVisible: true)
        snapshotLight(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_strategiesSelected_light() {
        let view = CustomTabBar(selectedTab: .constant(.strategies), isVisible: true)
        snapshotLight(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_settingsSelected_light() {
        let view = CustomTabBar(selectedTab: .constant(.settings), isVisible: true)
        snapshotLight(view, size: Sizes.tabBar)
    }

    func testCustomTabBar_settingsSelected_dark() {
        let view = CustomTabBar(selectedTab: .constant(.settings), isVisible: true)
        snapshotDark(view, size: Sizes.tabBar)
    }

    // MARK: - TabBarItem Tests

    func testTabBarItem_today_selected_light() {
        TabBarItemTestWrapper(tab: .today, isSelected: true)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_today_selected_dark() {
        TabBarItemTestWrapper(tab: .today, isSelected: true)
            .snapshotDark(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_today_unselected_light() {
        TabBarItemTestWrapper(tab: .today, isSelected: false)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_tasks_selected() {
        TabBarItemTestWrapper(tab: .tasks, isSelected: true)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_calendar_selected() {
        TabBarItemTestWrapper(tab: .calendar, isSelected: true)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_strategies_selected() {
        TabBarItemTestWrapper(tab: .strategies, isSelected: true)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }

    func testTabBarItem_settings_selected() {
        TabBarItemTestWrapper(tab: .settings, isSelected: true)
            .snapshotLight(size: Sizes.tabBarItem, testCase: self)
    }
}

// MARK: - TabBarItem Test Wrapper

/// A wrapper view to provide a namespace for TabBarItem.
/// TabBarItem requires a namespace for the matchedGeometryEffect.
private struct TabBarItemTestWrapper: View {
    let tab: AppTab
    let isSelected: Bool

    @Namespace private var namespace

    var body: some View {
        TabBarItem(tab: tab, isSelected: isSelected, namespace: namespace)
    }

    func snapshotLight(size: CGSize, testCase: SnapshotTestCase, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        let configured = self
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .light)
            .themed(WarmLightTheme())
            .hapticEngine(NoOpHapticEngine())

        assertSnapshot(
            of: configured,
            as: .image(precision: testCase.precision, perceptualPrecision: testCase.perceptualPrecision),
            file: file,
            testName: testName,
            line: line
        )
    }

    func snapshotDark(size: CGSize, testCase: SnapshotTestCase, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        let configured = self
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)
            .themed(WarmDarkTheme())
            .hapticEngine(NoOpHapticEngine())

        assertSnapshot(
            of: configured,
            as: .image(precision: testCase.precision, perceptualPrecision: testCase.perceptualPrecision),
            file: file,
            testName: testName,
            line: line
        )
    }
}
