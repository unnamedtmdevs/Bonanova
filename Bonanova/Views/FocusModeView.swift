import SwiftUI

struct FocusModeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @State private var completedAnimation = false

    private var urgentTasks: [PlannerTask] {
        plannerVM.urgentTasksForToday()
    }

    private var totalUrgentToday: [PlannerTask] {
        plannerVM.allTasksForSelectedDate().filter { $0.priority == .urgent }
    }

    private var completionRate: Double {
        let all = totalUrgentToday
        guard !all.isEmpty else { return 1.0 }
        let completed = all.filter { $0.isCompleted }.count
        return Double(completed) / Double(all.count)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(.systemBackground), Theme.urgent.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding(Theme.spacingMD)
                            .background(Circle().fill(Color(.systemFill)))
                    }
                    Spacer()
                    Text("Focus Mode")
                        .font(.system(size: 17, weight: .bold))
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Theme.spacingLG)
                .padding(.top, Theme.spacingLG)

                Spacer()

                // Progress ring
                VStack(spacing: Theme.spacingLG) {
                    ZStack {
                        ProgressRingView(
                            progress: completionRate,
                            colorName: "Action_Urgent",
                            size: 160,
                            lineWidth: 14
                        )

                        VStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.title)
                                .foregroundColor(Theme.urgent)
                            Text("\(Int(completionRate * 100))%")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.urgent)
                        }
                        .offset(y: 10)
                    }
                    .scaleEffect(completedAnimation && completionRate >= 1.0 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: completionRate)

                    VStack(spacing: 4) {
                        Text(completionRate >= 1.0 ? "All done! 🎉" : "Stay focused!")
                            .font(.system(size: 22, weight: .bold))

                        Text(urgentTasks.isEmpty
                             ? "No urgent tasks remaining"
                             : "\(urgentTasks.count) urgent task\(urgentTasks.count == 1 ? "" : "s") left")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Task list
                if urgentTasks.isEmpty && completionRate >= 1.0 {
                    // All done state
                    VStack(spacing: Theme.spacingMD) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.success)
                        Text("You crushed it today!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(Theme.spacingXXL)
                } else {
                    ScrollView {
                        VStack(spacing: Theme.spacingMD) {
                            ForEach(urgentTasks) { task in
                                FocusTaskRow(task: task) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        plannerVM.toggleCompletion(task: task)
                                        if plannerVM.urgentTasksForToday().isEmpty {
                                            completedAnimation = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.spacingLG)
                        .padding(.bottom, Theme.spacingXXL)
                    }
                }
            }
        }
    }
}

struct FocusTaskRow: View {
    let task: PlannerTask
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            Button(action: onComplete) {
                ZStack {
                    Circle()
                        .stroke(Theme.urgent, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundColor(Theme.urgent)
                        .opacity(0)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Label(task.timeSlot.rawValue, systemImage: task.timeSlot.icon)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "flame.fill")
                .foregroundColor(Theme.urgent)
                .font(.subheadline)
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerLG)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerLG)
                        .stroke(Theme.urgent.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Theme.urgent.opacity(0.1), radius: 6, x: 0, y: 2)
        )
    }
}
