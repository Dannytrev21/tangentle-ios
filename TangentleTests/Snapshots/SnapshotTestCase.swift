import XCTest
import SnapshotTesting
import SwiftUI
@testable import Tangentle

/// Base class for snapshot tests with common configuration and helper methods.
/// Provides consistent setup, theming, and precision settings across all snapshot tests.
class SnapshotTestCase: XCTestCase {

    /// Standard precision for snapshot comparisons.
    /// 0.99 allows for minor rendering differences while catching real regressions.
    let precision: Float = 0.99

    /// Standard perceptual precision for color-based comparison.
    let perceptualPrecision: Float = 0.98

    /// Recording mode - set to true to capture new baselines.
    /// Remember to set back to false after recording!
    var isRecordingEnabled: Bool {
        get { isRecording }
        set { isRecording = newValue }
    }

    override func setUp() {
        super.setUp()
        // Default: comparing mode
        // isRecording = true // Uncomment only when recording new baselines
    }

    // MARK: - Helper Methods

    /// Snapshot a SwiftUI view in light mode with theme and haptics configured.
    func snapshotLight<V: View>(
        _ view: V,
        size: CGSize,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let configured = view
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .light)
            .themed(WarmLightTheme())
            .hapticEngine(NoOpHapticEngine())

        assertSnapshot(
            of: configured,
            as: .image(precision: precision, perceptualPrecision: perceptualPrecision),
            file: file,
            testName: testName,
            line: line
        )
    }

    /// Snapshot a SwiftUI view in dark mode with theme and haptics configured.
    func snapshotDark<V: View>(
        _ view: V,
        size: CGSize,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let configured = view
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)
            .themed(WarmDarkTheme())
            .hapticEngine(NoOpHapticEngine())

        assertSnapshot(
            of: configured,
            as: .image(precision: precision, perceptualPrecision: perceptualPrecision),
            file: file,
            testName: testName,
            line: line
        )
    }

    /// Snapshot both light and dark variants of a view.
    func snapshotBothThemes<V: View>(
        _ view: V,
        size: CGSize,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        snapshotLight(view, size: size, file: file, testName: "\(testName)_light", line: line)
        snapshotDark(view, size: size, file: file, testName: "\(testName)_dark", line: line)
    }

    /// Create an in-memory Core Data context for test tasks.
    func makeTestContext() -> TestCoreDataStack {
        TestCoreDataStack()
    }
}

// MARK: - Common Sizes

extension SnapshotTestCase {
    /// Standard sizes for snapshot testing.
    struct Sizes {
        static let badge = CGSize(width: 100, height: 32)
        static let badgeWide = CGSize(width: 150, height: 32)
        static let checkbox = CGSize(width: 50, height: 50)
        static let completionIndicator = CGSize(width: 40, height: 40)
        static let taskCard = CGSize(width: 360, height: 100)
        static let taskCardTall = CGSize(width: 360, height: 140)
        static let taskRow = CGSize(width: 360, height: 70)
        static let tabBar = CGSize(width: 390, height: 80)
        static let tabBarItem = CGSize(width: 78, height: 56)
        static let floatingButton = CGSize(width: 70, height: 70)
        static let swipeActionButton = CGSize(width: 80, height: 70)
        static let swipeableRow = CGSize(width: 360, height: 70)
        static let statusBadge = CGSize(width: 100, height: 24)

        // Screen sizes for full-screen tests
        static let screen = CGSize(width: 390, height: 844)           // iPhone 14
        static let screenSmall = CGSize(width: 375, height: 667)      // iPhone SE
        static let screenLarge = CGSize(width: 430, height: 932)      // iPhone 15 Pro Max
    }
}
