import SwiftUI

// MARK: - Task Card

/// A redesigned task display component with warm aesthetics,
/// clear visual hierarchy, badges for metadata, and full accessibility.
struct TaskCard: View {
    @Environment(\.theme) var theme

    let task: TGTask
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Completion indicator
                CompletionIndicator(
                    isCompleted: task.isCompleted,
                    priority: task.taskPriority
                )

                // Content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    // Title
                    Text(task.title ?? "Untitled")
                        .font(Typography.bodyLarge)
                        .foregroundStyle(titleColor)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Metadata row
                    HStack(spacing: Spacing.sm) {
                        if let project = task.project {
                            ProjectBadge(project: project)
                        }

                        if task.isBlocked {
                            BlockedBadge()
                        }

                        if task.isOverdue {
                            OverdueBadge()
                        }
                    }
                }

                Spacer(minLength: Spacing.sm)

                // Right side: duration, priority, energy
                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                    if task.estimatedDuration > 0 {
                        DurationBadge(minutes: Int(task.estimatedDuration))
                    }

                    if task.taskPriority != .none {
                        PriorityBadge(priority: task.taskPriority)
                    }

                    if task.energy != .medium {
                        EnergyBadge(energy: task.energy)
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(cardBackground)
            .cornerRadius(CornerRadius.md)
            .shadow(
                color: theme.textPrimary.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("TaskCard_\(task.id?.uuidString ?? "unknown")")
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
    }

    // MARK: - Computed Properties

    private var titleColor: Color {
        if task.isCompleted { return theme.textTertiary }
        if task.isOverdue { return theme.statusError }
        return theme.textPrimary
    }

    private var cardBackground: Color {
        task.isCompleted ? theme.backgroundTertiary : theme.surfaceElevated
    }

    private var accessibilityLabel: String {
        var parts: [String] = []
        parts.append(task.title ?? "Untitled task")
        if task.isCompleted { parts.append("completed") }
        if task.isOverdue { parts.append("overdue") }
        if task.isBlocked { parts.append("blocked") }
        if let projectName = task.project?.name {
            parts.append("in project \(projectName)")
        }
        if task.estimatedDuration > 0 {
            parts.append("\(Int(task.estimatedDuration)) minutes")
        }
        if task.taskPriority != .none {
            parts.append("\(task.taskPriority.displayName) priority")
        }
        if task.energy != .medium {
            parts.append("\(task.energy.displayName) energy")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#if DEBUG
struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.md) {
            TaskCard(task: previewTask(
                title: "Review quarterly report",
                priority: .high,
                duration: 30,
                completed: false
            )) { }

            TaskCard(task: previewTask(
                title: "A completed task with a longer title that might wrap to two lines",
                priority: .medium,
                duration: 15,
                completed: true
            )) { }

            TaskCard(task: previewTask(
                title: "Blocked task waiting on dependencies",
                priority: .low,
                duration: 45,
                completed: false,
                blocked: true
            )) { }

            TaskCard(task: previewTask(
                title: "Overdue task that needs attention",
                priority: .high,
                duration: 60,
                completed: false,
                overdue: true
            )) { }
        }
        .padding()
        .background(WarmLightTheme().backgroundPrimary)
        .themed(WarmLightTheme())
    }

    static func previewTask(
        title: String,
        priority: Priority,
        duration: Int16,
        completed: Bool,
        blocked: Bool = false,
        overdue: Bool = false
    ) -> TGTask {
        let context = PersistenceController.preview.viewContext
        let task = TGTask(context: context)
        task.id = UUID()
        task.title = title
        task.taskPriority = priority
        task.estimatedDuration = duration
        task.status = completed ? "done" : "pending"
        task.energy = .high

        if overdue {
            task.dueDate = Date().addingTimeInterval(-86400) // Yesterday
        }

        if blocked {
            let blocker = TGTask(context: context)
            blocker.id = UUID()
            blocker.title = "Blocker"
            blocker.status = "pending"
            task.addBlocker(blocker)
        }

        // Add a project to first task
        let project = TGProject(context: context)
        project.id = UUID()
        project.name = "Work"
        project.emoji = "💼"
        task.project = project

        return task
    }
}
#endif
