import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            List {
                AppearanceSettingsSection()

                Section("Schedule") {
                    Text("Work hours: 9am - 5pm")
                        .foregroundStyle(theme.textPrimary)
                    Text("Peak focus: 9am - 12pm")
                        .foregroundStyle(theme.textPrimary)
                }

                Section("Tasks") {
                    Text("Default duration: 30 min")
                        .foregroundStyle(theme.textPrimary)
                }

                Section("About") {
                    Text("Tangentle v1.0")
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .background(theme.backgroundPrimary)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    SettingsView()
        .themed(WarmLightTheme())
        .hapticEngine(NoOpHapticEngine())
}
