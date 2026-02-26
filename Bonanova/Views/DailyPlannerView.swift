import SwiftUI

struct DailyPlannerView: View {
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var storage: PlannerStorageService
    @State private var showAddTask = false
    @State private var defaultSlot: TimeSlot = .morning
    @State private var isEditing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date scroller
                DateScrollerView(selectedDate: $plannerVM.selectedDate)
                    .padding(.vertical, Theme.spacingMD)
                    .background(Theme.bgSecondary)

                // Completion progress
                if !plannerVM.allTasksForSelectedDate().isEmpty {
                    let rate = plannerVM.completionRate(for: plannerVM.selectedDate)
                    HStack(spacing: Theme.spacingMD) {
                        SmallProgressBar(progress: rate, colorName: "Action_Success")
                        Text("\(Int(rate * 100))%")
                            .font(.caption.bold())
                            .foregroundColor(Theme.success)
                    }
                    .padding(.horizontal, Theme.spacingLG)
                    .padding(.vertical, Theme.spacingSM)
                    .background(Color(.systemBackground))
                }

                // Task list
                List {
                    ForEach(TimeSlot.allCases) { slot in
                        Section {
                            let slotTasks = plannerVM.tasks(for: slot)
                            if slotTasks.isEmpty {
                                Button(action: {
                                    defaultSlot = slot
                                    showAddTask = true
                                }) {
                                    Label("Add a task", systemImage: "plus")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.namedColor(slot.colorName))
                                }
                            } else {
                                ForEach(slotTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        category: plannerVM.categoryFor(id: task.categoryId),
                                        onToggle: { plannerVM.toggleCompletion(task: task) },
                                        onDelete: { plannerVM.deleteTask(task) }
                                    )
                                    .listRowInsets(EdgeInsets(
                                        top: 4, leading: 12, bottom: 4, trailing: 12
                                    ))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                .onMove { source, dest in
                                    plannerVM.moveTasks(slot: slot, from: source, to: dest)
                                }
                                .onDelete { offsets in
                                    plannerVM.deleteTasks(slot: slot, at: offsets)
                                }
                            }
                        } header: {
                            SlotHeaderView(slot: slot, count: plannerVM.tasks(for: slot).count) {
                                defaultSlot = slot
                                showAddTask = true
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            }
            .background(Theme.bgPrimary.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Daily Planner")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Reorder") {
                        withAnimation { isEditing.toggle() }
                    }
                    .font(.subheadline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        defaultSlot = .morning
                        showAddTask = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(defaultSlot: defaultSlot)
                    .environmentObject(plannerVM)
                    .environmentObject(storage)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Date Scroller

struct DateScrollerView: View {
    @Binding var selectedDate: Date

    private let dates: [Date] = {
        let today = Calendar.current.startOfDay(for: Date())
        return (-14...30).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: today)
        }
    }()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.spacingSM) {
                    ForEach(dates, id: \.self) { date in
                        DateCell(date: date, isSelected: DateHelper.shared.isSameDay(date, selectedDate))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }
                            .id(date)
                    }
                }
                .padding(.horizontal, Theme.spacingLG)
            }
            .onAppear {
                let today = Calendar.current.startOfDay(for: Date())
                proxy.scrollTo(today, anchor: .center)
            }
        }
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(DateHelper.shared.shortDayName(date))
                .font(.caption2)
                .foregroundColor(isSelected ? .white : .secondary)

            Text(DateHelper.shared.dayNumber(date))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isSelected ? .white : (isToday ? Theme.primary : .primary))
        }
        .frame(width: 44, height: 58)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerMD)
                .fill(isSelected ? Theme.primary : Color.white.opacity(isToday ? 0.5 : 0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerMD)
                .stroke(isToday && !isSelected ? Theme.primary : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Slot Header

struct SlotHeaderView: View {
    let slot: TimeSlot
    let count: Int
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: slot.icon)
                .foregroundColor(Theme.namedColor(slot.colorName))
                .font(.subheadline)

            Text(slot.rawValue)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)

            if count > 0 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.namedColor(slot.colorName).opacity(0.2))
                    .foregroundColor(Theme.namedColor(slot.colorName))
                    .cornerRadius(10)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Theme.namedColor(slot.colorName))
                    .font(.title3)
            }
        }
        .padding(.horizontal, Theme.spacingLG)
        .padding(.vertical, Theme.spacingSM)
        .background(Theme.bgPrimary.opacity(0.5))
    }
}

// MARK: - Add Task Sheet

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var storage: PlannerStorageService

    let defaultSlot: TimeSlot

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedSlot: TimeSlot
    @State private var selectedPriority: TaskPriority = .normal
    @State private var selectedCategoryId: UUID? = nil
    @FocusState private var titleFocused: Bool

    init(defaultSlot: TimeSlot) {
        self.defaultSlot = defaultSlot
        self._selectedSlot = State(initialValue: defaultSlot)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $title)
                        .focused($titleFocused)
                    TextField("Notes (optional)", text: $notes)
                }

                Section("Schedule") {
                    Picker("Time Slot", selection: $selectedSlot) {
                        ForEach(TimeSlot.allCases) { slot in
                            Label(slot.rawValue, systemImage: slot.icon).tag(slot)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Priority") {
                    HStack(spacing: Theme.spacingSM) {
                        ForEach(TaskPriority.allCases) { priority in
                            PriorityPillButton(
                                priority: priority,
                                isSelected: selectedPriority == priority
                            ) {
                                selectedPriority = priority
                            }
                        }
                    }
                    .padding(.vertical, Theme.spacingXS)
                }

                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.spacingSM) {
                            CategoryPill(name: "None", colorName: "BG_Secondary", isSelected: selectedCategoryId == nil) {
                                selectedCategoryId = nil
                            }
                            ForEach(storage.categories) { cat in
                                CategoryPill(name: cat.name, colorName: cat.colorName, isSelected: selectedCategoryId == cat.id) {
                                    selectedCategoryId = cat.id
                                }
                            }
                        }
                        .padding(.vertical, Theme.spacingXS)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        plannerVM.addTask(
                            title: title.trimmingCharacters(in: .whitespaces),
                            notes: notes,
                            slot: selectedSlot,
                            priority: selectedPriority,
                            categoryId: selectedCategoryId
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

struct PriorityPillButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(priority.rawValue, systemImage: priority.icon)
                .font(.caption.bold())
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(
                    isSelected
                    ? Theme.priorityColor(priority)
                    : Theme.priorityColor(priority).opacity(0.15)
                )
                .foregroundColor(isSelected ? .white : Theme.priorityColor(priority))
                .cornerRadius(Theme.cornerLG)
        }
        .buttonStyle(.plain)
    }
}

struct CategoryPill: View {
    let name: String
    let colorName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption.bold())
                .padding(.horizontal, Theme.spacingMD)
                .padding(.vertical, Theme.spacingSM)
                .background(
                    isSelected
                    ? Theme.namedColor(colorName)
                    : Theme.namedColor(colorName).opacity(0.15)
                )
                .foregroundColor(isSelected ? .white : Theme.namedColor(colorName))
                .cornerRadius(Theme.cornerLG)
        }
        .buttonStyle(.plain)
    }
}
