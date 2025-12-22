import SwiftUI

struct CalendarView: View {
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Calendar",
                systemImage: "calendar",
                description: Text("Calendar view coming soon")
            )
            .foregroundStyle(theme.textSecondary)
            .navigationTitle("Calendar")
            .background(theme.backgroundPrimary)
        }
    }
}

#Preview {
    CalendarView()
        .themed(WarmLightTheme())
}
