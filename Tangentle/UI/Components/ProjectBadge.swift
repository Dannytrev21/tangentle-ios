import SwiftUI

// MARK: - Project Badge

/// A badge displaying the project name with optional emoji prefix.
struct ProjectBadge: View {
    @Environment(\.theme) var theme

    let project: TGProject

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            if let emoji = project.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.system(size: 11))
            } else {
                Image(systemName: "folder.fill")
                    .font(.system(size: 10))
            }
            Text(project.name ?? "Project")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.textSecondary)
        .lineLimit(1)
        .accessibilityLabel("In project \(project.name ?? "unnamed")")
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.sm) {
            ProjectBadge(project: makePreviewProject(name: "Work", emoji: "💼"))
            ProjectBadge(project: makePreviewProject(name: "Personal", emoji: "🏠"))
            ProjectBadge(project: makePreviewProject(name: "No Emoji", emoji: nil))
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }

    static func makePreviewProject(name: String, emoji: String?) -> TGProject {
        let context = PersistenceController.preview.viewContext
        let project = TGProject(context: context)
        project.id = UUID()
        project.name = name
        project.emoji = emoji
        return project
    }
}
#endif
