import SwiftUI

struct TasksView: View {
    @Environment(\.container) var container

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "All Tasks",
                systemImage: "checklist",
                description: Text("Task list coming soon")
            )
            .navigationTitle("Tasks")
        }
    }
}

#Preview {
    TasksView()
        .withContainer(TestContainer())
}
