import SwiftUI

struct TaskCardView: View {
    let task: PlannerTask
    let category: TaskCategory?
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var showDelete = false

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            // Priority stripe
            RoundedRectangle(cornerRadius: 3)
                .fill(Theme.priorityColor(task.priority))
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            // Completion toggle
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? Theme.success : Color.secondary)
            }
            .buttonStyle(.plain)

            // Content
            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: Theme.spacingSM) {
                    // Priority badge
                    Label(task.priority.rawValue, systemImage: task.priority.icon)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.priorityColor(task.priority).opacity(0.15))
                        .foregroundColor(Theme.priorityColor(task.priority))
                        .cornerRadius(Theme.cornerSM)

                    // Category badge
                    if let cat = category {
                        Text(cat.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.namedColor(cat.colorName).opacity(0.15))
                            .foregroundColor(Theme.namedColor(cat.colorName))
                            .cornerRadius(Theme.cornerSM)
                    }
                }
            }

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(Theme.urgent.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerMD)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .opacity(task.isCompleted ? 0.75 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }
}
