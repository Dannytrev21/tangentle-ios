import SwiftUI

struct ContentView: View {
    @Environment(\.container) var container
    @State private var selectedTab: Tab = .today

    enum Tab {
        case today
        case tasks
        case calendar
        case strategies
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            TasksView()
                .tabItem {
                    Label("", systemImage: "checklist")
                }
                .tag(Tab.tasks)

            CalendarView()
                .tabItem {
                    Label("", systemImage: "calendar")
                }
                .tag(Tab.calendar)
            
            TodayView()
                .tabItem {
                    Label("",systemImage: "sun.max")
                }
                .tag(Tab.today)

            StrategiesView()
                .tabItem {
                    Label("", systemImage: "lightbulb")
                }
                .tag(Tab.strategies)

            SettingsView()
                .tabItem {
                    Label("", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .withContainer(TestContainer())
}
