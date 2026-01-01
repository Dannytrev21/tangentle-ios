import Foundation
@testable import Tangentle

/// Infrastructure for loading JSON test fixtures
struct TestFixtures {

    /// Load and decode a JSON fixture file
    static func load<T: Decodable>(_ filename: String) throws -> T {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: filename, withExtension: "json", subdirectory: "Fixtures") else {
            throw FixtureError.fileNotFound(filename)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    /// Load task fixtures
    static func loadTasks(_ filename: String) throws -> [TaskFixture] {
        return try load(filename)
    }

    /// Load strategy fixtures
    static func loadStrategies(_ filename: String) throws -> [StrategyFixture] {
        return try load(filename)
    }
}

// MARK: - Fixture Models

struct TaskFixture: Decodable {
    let title: String
    let status: String
    let priority: Int
    let estimatedDuration: Int
    let scheduledDate: Date?
    let dueDate: Date?
}

struct StrategyFixture: Decodable {
    let name: String
    let description: String
    let problemTypes: [String]
    let source: String
}

// MARK: - Errors

enum FixtureError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Fixture file not found: \(name).json"
        case .decodingFailed(let name):
            return "Failed to decode fixture: \(name).json"
        }
    }
}

// Bundle token for locating test resources
private class BundleToken {}
