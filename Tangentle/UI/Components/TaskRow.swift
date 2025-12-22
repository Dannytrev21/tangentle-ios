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

                    if task.priority > 0 {
                        PriorityBadge(priority: Int(task.priority))
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

struct PriorityBadge: View {
    let priority: Int

    var body: some View {
        Text(priorityText)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.15))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }

    private var priorityText: String {
        switch priority {
        case 5: return "HIGH"
        case 3...4: return "MED"
        default: return "LOW"
        }
    }

    private var priorityColor: Color {
        switch priority {
        case 5: return .red
        case 3...4: return .orange
        default: return .blue
        }
    }
}

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
