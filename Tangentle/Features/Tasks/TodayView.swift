import SwiftUI

// MARK: - Today View

/// The main Today screen showing tasks due today and overdue tasks.
/// Features warm aesthetics, swipeable task cards, and fluid animations.
struct TodayView: View {
    @Environment(\.container) var container
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    @State private var viewModel: TodayViewModel?
    @State private var showAddTask = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    TodayHeader()
                        .padding(.horizontal, Spacing.md)

                    if let vm = viewModel {
                        TodayContent(viewModel: vm)
                    } else {
                        ProgressView()
                            .padding(.top, Spacing.xxl)
                    }
                }
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxxl)
            }
            .refreshable {
                await viewModel?.loadTasks()
            }
            .background(theme.backgroundPrimary)

            FloatingActionButton {
                showAddTask = true
            }
            .padding(.trailing, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .task {
            viewModel = TodayViewModel(
                taskService: container.taskService,
                scheduleService: container.scheduleService
            )
            await viewModel?.loadTasks()
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskPlaceholder()
        }
    }
}

// MARK: - Today Content

/// The scrollable content area containing task sections.
private struct TodayContent: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics
    @Bindable var viewModel: TodayViewModel

    var body: some View {
        LazyVStack(spacing: Spacing.md) {
            // Overdue section
            if !viewModel.overdueTasks.isEmpty {
                TaskSection(
                    title: "Overdue",
                    icon: "exclamationmark.triangle.fill",
                    iconColor: theme.statusError,
                    count: viewModel.overdueTasks.count
                ) {
                    ForEach(viewModel.overdueTasks, id: \.id) { task in
                        taskRow(task, isOverdue: true)
                    }
                }
            }

            // Today section
            TaskSection(
                title: "Today",
                icon: "calendar",
                iconColor: theme.accentPrimary,
                count: viewModel.todaysTasks.count
            ) {
                if viewModel.todaysTasks.isEmpty && viewModel.overdueTasks.isEmpty {
                    TodayEmptyState()
                } else if viewModel.todaysTasks.isEmpty {
                    Text("All caught up for today!")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                } else {
                    ForEach(viewModel.todaysTasks, id: \.id) { task in
                        taskRow(task, isOverdue: false)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Task Row

    @ViewBuilder
    private func taskRow(_ task: TGTask, isOverdue: Bool) -> some View {
        SwipeableRow(
            leadingActions: [
                StandardSwipeActions.complete {
                    Task { await viewModel.completeTask(task) }
                }
            ],
            trailingActions: trailingActions(for: task)
        ) {
            TaskCard(task: task) {
                // Navigate to task detail
            }
        }
    }

    private func trailingActions(for task: TGTask) -> [SwipeAction] {
        var actions: [SwipeAction] = []

        // Contextual action: unblock if blocked
        if task.isBlocked {
            actions.append(StandardSwipeActions.unblock {
                // Unblock action - to be implemented
            })
        }

        // Standard actions
        actions.append(contentsOf: [
            StandardSwipeActions.defer_ {
                Task { await viewModel.deferTask(task) }
            },
            StandardSwipeActions.delete {
                Task { await viewModel.deleteTask(task) }
            }
        ])

        return actions
    }
}

// MARK: - Add Task Placeholder

/// Placeholder view for the add task sheet.
/// Will be replaced with full implementation later.
private struct AddTaskPlaceholder: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.textTertiary)

                Text("Add Task")
                    .font(Typography.titleMedium)
                    .foregroundStyle(theme.textPrimary)

                Text("Coming soon...")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundPrimary)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .themed(WarmLightTheme())
            .hapticEngine(NoOpHapticEngine())
            .withContainer(TestContainer())
    }
}
#endif
