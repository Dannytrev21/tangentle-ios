import SwiftUI

// MARK: - Swipe Action Model

/// A configurable action that can be triggered via swipe gesture.
/// Used with SwipeableRow to provide swipe-to-reveal functionality.
struct SwipeAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let isDestructive: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String,
        color: Color,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isDestructive = isDestructive
        self.action = action
    }
}

// MARK: - Standard Actions Factory

/// Factory for commonly used swipe actions in the app.
/// Provides consistent styling and behavior across all swipeable rows.
enum StandardSwipeActions {
    /// Complete action - marks a task as done
    static func complete(onComplete: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Done",
            icon: "checkmark.circle.fill",
            color: LightColors.statusSuccess, // Green
            action: onComplete
        )
    }

    /// Delete action - removes item (destructive)
    static func delete(onDelete: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Delete",
            icon: "trash.fill",
            color: LightColors.statusError, // Red
            isDestructive: true,
            action: onDelete
        )
    }

    /// Defer action - postpone to later
    static func defer_(onDefer: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Defer",
            icon: "clock.arrow.circlepath",
            color: LightColors.statusWarning, // Amber
            action: onDefer
        )
    }

    /// Edit action - open editor
    static func edit(onEdit: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Edit",
            icon: "pencil",
            color: LightColors.statusInfo, // Blue
            action: onEdit
        )
    }

    /// Unblock action - for blocked tasks
    static func unblock(onUnblock: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Unblock",
            icon: "arrow.uturn.forward",
            color: LightColors.accentPrimary, // Amber accent
            action: onUnblock
        )
    }

    /// Duplicate action - create a copy
    static func duplicate(onDuplicate: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Copy",
            icon: "doc.on.doc",
            color: LightColors.textSecondary, // Gray
            action: onDuplicate
        )
    }
}
