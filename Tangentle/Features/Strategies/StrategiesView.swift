import SwiftUI

struct StrategiesView: View {
    @Environment(\.container) var container
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Strategy Coaching",
                systemImage: "lightbulb",
                description: Text("Coaching features coming soon")
            )
            .foregroundStyle(theme.textSecondary)
            .navigationTitle("Strategies")
            .background(theme.backgroundPrimary)
        }
    }
}

#Preview {
    StrategiesView()
        .themed(WarmLightTheme())
        .withContainer(TestContainer())
}
