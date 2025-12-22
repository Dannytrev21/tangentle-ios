import SwiftUI

@main
struct TangentleApp: App {
    @State private var themeManager = ThemeManager()
    @Environment(\.colorScheme) private var systemColorScheme
    private let container: DIContainer = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            TabBarContainer()
                .environment(\.theme, themeManager.currentTheme)
                .environment(\.themeManager, themeManager)
                .environment(\.hapticEngine, container.hapticEngine)
                .environment(\.container, container)
                .environment(\.managedObjectContext, container.viewContext)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    container.hapticEngine.prepare()
                    themeManager.updateSystemColorScheme(systemColorScheme)
                }
                .onChange(of: systemColorScheme) { _, newScheme in
                    themeManager.updateSystemColorScheme(newScheme)
                }
                .task {
                    await Self.setupFirstLaunch()
                }
        }
    }

    private static func setupFirstLaunch() async {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            do {
                try await seedDefaultData()
                defaults.set(true, forKey: "hasLaunchedBefore")
            } catch {
                print("Failed to seed data: \(error)")
            }
        }
    }

    private static func seedDefaultData() async throws {
        let seedService = SeedDataService(context: AppContainer.shared.viewContext)
        try await seedService.seedIfNeeded()
    }
}
