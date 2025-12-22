import SwiftUI

// MARK: - Theme Preview Wrapper

/// A preview helper that shows content side-by-side in light and dark themes.
/// Useful for verifying theme consistency during development.
///
/// Usage:
/// ```swift
/// #Preview {
///     ThemePreviewWrapper {
///         TaskCard(task: previewTask()) {}
///     }
/// }
/// ```
struct ThemePreviewWrapper<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        HStack(spacing: 0) {
            content()
                .environment(\.theme, WarmLightTheme())
                .colorScheme(.light)
                .frame(maxWidth: .infinity)

            content()
                .environment(\.theme, WarmDarkTheme())
                .colorScheme(.dark)
                .frame(maxWidth: .infinity)
        }
        .hapticEngine(NoOpHapticEngine())
    }
}

// MARK: - Preview Helpers

/// Helper for creating mock tasks for previews
#if DEBUG
func previewTask(
    title: String = "Sample Task",
    isCompleted: Bool = false,
    isOverdue: Bool = false,
    priority: Priority = .medium
) -> TGTask {
    let context = PersistenceController.preview.viewContext
    let task = TGTask(context: context)
    task.id = UUID()
    task.title = title
    task.status = isCompleted ? TaskStatus.done.rawValue : TaskStatus.pending.rawValue
    task.taskPriority = priority
    task.estimatedDuration = 30
    task.createdAt = Date()
    task.updatedAt = Date()

    if isOverdue {
        task.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    } else {
        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
    }

    return task
}

/// Preview showing component in both themes
struct ThemePreviewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreviewWrapper {
            VStack(spacing: Spacing.md) {
                Text("Light vs Dark")
                    .font(Typography.titleMedium)

                Text("Both themes should look warm and inviting")
                    .font(Typography.bodyMedium)
            }
            .padding()
        }
    }
}
#endif
