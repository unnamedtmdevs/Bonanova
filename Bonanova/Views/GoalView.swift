import SwiftUI

struct GoalView: View {
    @EnvironmentObject private var goalVM: GoalViewModel
    @State private var showAddGoal = false
    @State private var expandedGoalId: UUID? = nil

    var body: some View {
        NavigationView {
            Group {
                if goalVM.goals.isEmpty {
                    emptyState
                } else {
                    goalList
                }
            }
            .background(Theme.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Goals")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView()
                    .environmentObject(goalVM)
            }
        }
        .navigationViewStyle(.stack)
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingXL) {
            Image(systemName: "target")
                .font(.system(size: 72))
                .foregroundColor(Theme.creative.opacity(0.5))

            Text("No Goals Yet")
                .font(.title2.bold())

            Text("Break big dreams into achievable steps. Tap + to create your first goal.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingXXL)

            Button(action: { showAddGoal = true }) {
                Label("Create Goal", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.spacingXXL)
                    .frame(height: 50)
                    .background(Theme.creative)
                    .cornerRadius(Theme.cornerLG)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var goalList: some View {
        ScrollView {
            VStack(spacing: Theme.spacingMD) {
                // Overall progress
                overallProgressCard

                // Goal cards
                ForEach(goalVM.goals) { goal in
                    GoalCard(
                        goal: goal,
                        isExpanded: expandedGoalId == goal.id
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            expandedGoalId = expandedGoalId == goal.id ? nil : goal.id
                        }
                    }
                    .environmentObject(goalVM)
                    .contextMenu {
                        Button(role: .destructive) {
                            goalVM.deleteGoal(goal)
                        } label: {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.spacingLG)
            .padding(.bottom, Theme.spacingXXL)
        }
    }

    private var overallProgressCard: some View {
        HStack(spacing: Theme.spacingXL) {
            ProgressRingView(
                progress: goalVM.overallProgress(),
                colorName: "Action_Creative",
                size: 80,
                lineWidth: 8
            )

            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("Overall Progress")
                    .font(.system(size: 16, weight: .bold))

                Text("\(goalVM.completedGoalsCount()) of \(goalVM.goals.count) goals completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                let allSubtasks = goalVM.goals.flatMap { $0.subtasks }
                let completedSubtasks = allSubtasks.filter { $0.isCompleted }.count
                Text("\(completedSubtasks)/\(allSubtasks.count) subtasks done")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(Theme.spacingLG)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerLG)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Goal Card

struct GoalCard: View {
    let goal: Goal
    let isExpanded: Bool
    let onTap: () -> Void

    @EnvironmentObject private var goalVM: GoalViewModel
    @State private var showAddSubtask = false
    @State private var newSubtaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack(spacing: Theme.spacingMD) {
                    ProgressRingView(
                        progress: goal.completionRate,
                        colorName: goal.colorName,
                        size: 52,
                        lineWidth: 5
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(goal.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            if goal.isCompleted {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Theme.success)
                                    .font(.caption)
                            }
                        }

                        if !goal.goalDescription.isEmpty {
                            Text(goal.goalDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        HStack(spacing: Theme.spacingXS) {
                            Text("\(goal.completedCount)/\(goal.subtasks.count) subtasks")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let target = goal.targetDate {
                                Text("· Due \(DateHelper.shared.mediumDateString(target))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(Theme.spacingMD)
            }
            .buttonStyle(.plain)

            // Progress bar
            SmallProgressBar(progress: goal.completionRate, colorName: goal.colorName)
                .padding(.horizontal, Theme.spacingMD)
                .padding(.bottom, Theme.spacingMD)

            // Expanded subtasks
            if isExpanded {
                Divider().padding(.horizontal, Theme.spacingMD)

                VStack(spacing: 0) {
                    ForEach(goal.subtasks) { subtask in
                        SubtaskRowView(
                            subtask: subtask,
                            goalColorName: goal.colorName
                        ) {
                            goalVM.toggleSubtask(goalId: goal.id, subtaskId: subtask.id)
                        } onDelete: {
                            goalVM.deleteSubtask(goalId: goal.id, subtaskId: subtask.id)
                        }
                    }

                    // Add subtask input
                    if showAddSubtask {
                        HStack {
                            TextField("New subtask...", text: $newSubtaskTitle)
                                .font(.subheadline)
                                .submitLabel(.done)
                                .onSubmit { saveSubtask() }

                            Button(action: saveSubtask) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.success)
                            }
                            .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)

                            Button(action: { showAddSubtask = false; newSubtaskTitle = "" }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(Theme.spacingMD)
                    }

                    // Add subtask button
                    if !showAddSubtask {
                        Button(action: { showAddSubtask = true }) {
                            Label("Add Subtask", systemImage: "plus")
                                .font(.subheadline)
                                .foregroundColor(Theme.namedColor(goal.colorName))
                        }
                        .padding(Theme.spacingMD)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerLG)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }

    private func saveSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        goalVM.addSubtask(to: goal.id, title: trimmed)
        newSubtaskTitle = ""
        showAddSubtask = false
    }
}

// MARK: - Subtask Row

struct SubtaskRowView: View {
    let subtask: Subtask
    let goalColorName: String
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Theme.spacingMD) {
            Button(action: onToggle) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(subtask.isCompleted ? Theme.namedColor(goalColorName) : .secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .font(.subheadline)
                .strikethrough(subtask.isCompleted)
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "minus.circle")
                    .foregroundColor(.secondary.opacity(0.6))
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.spacingMD)
        .padding(.vertical, Theme.spacingSM)
        .animation(.easeInOut(duration: 0.2), value: subtask.isCompleted)
    }
}

// MARK: - Add Goal Sheet

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var goalVM: GoalViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedColorName = "Action_Primary"
    @State private var hasTargetDate = false
    @State private var targetDate = Date().addingTimeInterval(30 * 24 * 3600)
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal title", text: $title)
                        .focused($titleFocused)
                    TextField("Description (optional)", text: $description)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Theme.spacingMD) {
                        ForEach(Theme.goalColorOptions, id: \.name) { option in
                            Circle()
                                .fill(option.color)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorName == option.name ? 3 : 0)
                                        .padding(2)
                                )
                                .onTapGesture {
                                    selectedColorName = option.name
                                }
                        }
                    }
                    .padding(.vertical, Theme.spacingXS)
                }

                Section("Target Date") {
                    Toggle("Set target date", isOn: $hasTargetDate)
                    if hasTargetDate {
                        DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        goalVM.addGoal(
                            title: title.trimmingCharacters(in: .whitespaces),
                            description: description,
                            colorName: selectedColorName,
                            targetDate: hasTargetDate ? targetDate : nil
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .font(.headline)
                }
            }
            .onAppear { titleFocused = true }
        }
    }
}
