import Foundation
import CoreData
@testable import Tangentle

// MARK: - Common Mock Error

/// Error for intentional test failures
enum MockError: Error, LocalizedError {
    case intentional
    case notImplemented
    case notFound

    var errorDescription: String? {
        switch self {
        case .intentional:
            return "Intentional mock error for testing"
        case .notImplemented:
            return "Mock method not implemented"
        case .notFound:
            return "Entity not found"
        }
    }
}

// MARK: - Method Call Tracking

/// Records a method call for verification
struct MethodCall {
    let name: String
    let arguments: [String: Any]
    let timestamp: Date

    init(name: String, arguments: [String: Any] = [:]) {
        self.name = name
        self.arguments = arguments
        self.timestamp = Date()
    }
}

/// Protocol for mocks that track method calls
protocol MockSpy: AnyObject {
    var calls: [MethodCall] { get set }
    func wasCalled(_ methodName: String) -> Bool
    func callCount(_ methodName: String) -> Int
    func lastCall(_ methodName: String) -> MethodCall?
    func clearCalls()
}

/// Default implementation for MockSpy
extension MockSpy {
    func wasCalled(_ methodName: String) -> Bool {
        calls.contains { $0.name == methodName }
    }

    func callCount(_ methodName: String) -> Int {
        calls.filter { $0.name == methodName }.count
    }

    func lastCall(_ methodName: String) -> MethodCall? {
        calls.last { $0.name == methodName }
    }

    func clearCalls() {
        calls.removeAll()
    }
}

// MARK: - Base Mock Repository

/// Base class for repository mocks with common functionality
class BaseMockRepository: MockSpy {
    var calls: [MethodCall] = []
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false
    var saveError: Error = MockError.intentional
    var deleteError: Error = MockError.intentional

    func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func reset() {
        calls.removeAll()
        shouldThrowOnSave = false
        shouldThrowOnDelete = false
    }
}

// MARK: - Mock Context

/// A mock context property that satisfies Repository protocol but throws when used
/// Mocks don't need actual Core Data contexts - use TestCoreDataStack for real entities
class MockContext {
    static let shared: NSManagedObjectContext = {
        fatalError("Mock repositories don't use real contexts. Use TestCoreDataStack to create entities.")
    }()
}
