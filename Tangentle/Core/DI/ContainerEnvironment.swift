import SwiftUI

/// Environment key for DI container
private struct ContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = AppContainer.shared
}

extension EnvironmentValues {
    var container: DIContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

extension View {
    /// Inject a custom DI container
    func withContainer(_ container: DIContainer) -> some View {
        environment(\.container, container)
    }
}
