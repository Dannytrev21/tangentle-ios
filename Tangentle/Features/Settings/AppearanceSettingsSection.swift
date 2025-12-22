import SwiftUI

// MARK: - Appearance Settings Section

/// Settings section for appearance customization including theme, haptics, and tab bar.
struct AppearanceSettingsSection: View {
    @Environment(\.theme) var theme
    @Environment(\.themeManager) var themeManager
    @Environment(\.hapticEngine) var hapticEngine

    @AppStorage("hapticIntensity") private var hapticIntensity = "selective"
    @AppStorage("hideTabBar") private var hideTabBar = false

    var body: some View {
        Section {
            // Theme picker
            Picker("Theme", selection: Binding(
                get: { themeManager.mode },
                set: { themeManager.mode = $0 }
            )) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .tint(theme.accentPrimary)

            // Haptic intensity picker
            Picker("Haptic Feedback", selection: $hapticIntensity) {
                Text("Off").tag("off")
                Text("Selective").tag("selective")
                Text("Rich").tag("rich")
            }
            .tint(theme.accentPrimary)
            .onChange(of: hapticIntensity) { _, newValue in
                updateHapticIntensity(newValue)
            }

            // Tab bar visibility toggle
            Toggle("Hide Tab Bar", isOn: $hideTabBar)
                .tint(theme.accentPrimary)
        } header: {
            Text("Appearance")
        }
    }

    // MARK: - Private Methods

    private func updateHapticIntensity(_ value: String) {
        let intensity: HapticIntensity
        switch value {
        case "off":
            intensity = .off
        case "rich":
            intensity = .rich
        default:
            intensity = .selective
        }
        hapticEngine.updateIntensity(intensity)
    }
}

// MARK: - Preview

#if DEBUG
struct AppearanceSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            AppearanceSettingsSection()
        }
        .themed(WarmLightTheme())
        .hapticEngine(NoOpHapticEngine())
    }
}
#endif
