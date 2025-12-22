import SwiftUI

struct TaskRow: View {
    let task: TGTask

    var body: some View {
        HStack(spacing: 12) {
            // Completion circle
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(task.isCompleted ? .green : .secondary)

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled")
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let project = task.project {
                        HStack(spacing: 4) {
                            if let emoji = project.emoji {
                                Text(emoji)
                            }
                            Text(project.name ?? "")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if task.estimatedDuration > 0 {
                        Label("\(task.estimatedDuration)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if task.taskPriority != .none {
                        PriorityBadge(priority: task.taskPriority)
                    }
                }
            }

            Spacer()

            // Status indicators
            if task.isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }

            if task.isBlocked {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// NOTE: PriorityBadge moved to PriorityBadge.swift with full theme integration

#Preview {
    List {
        TaskRow(task: previewTask())
    }
}

private func previewTask() -> TGTask {
    let context = PersistenceController.preview.viewContext
    let task = TGTask(context: context)
    task.id = UUID()
    task.title = "Sample Task"
    task.estimatedDuration = 30
    task.priority = 5
    task.status = "pending"
    return task
}
