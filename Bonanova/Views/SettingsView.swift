import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var storage: PlannerStorageService
    @AppStorage("defaultPriority") private var defaultPriority: String = TaskPriority.normal.rawValue
    @AppStorage("accentPreference") private var accentPreference: String = "Action_Primary"
    @AppStorage("themeIntensity") private var themeIntensity: Double = 1.0
    @AppStorage("hasOnboarded") private var hasOnboarded = true
    @State private var showResetConfirm = false
    @State private var showResetOnboardingConfirm = false
    @State private var showCategorySheet = false

    var body: some View {
        NavigationView {
            Form {
                // Appearance
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Theme Intensity")
                            .font(.subheadline)
                        HStack {
                            Image(systemName: "sun.min")
                                .foregroundColor(.secondary)
                            Slider(value: $themeIntensity, in: 0.3...1.0, step: 0.1)
                                .accentColor(Theme.primary)
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(Theme.primary)
                        }
                        Text("Controls background and card vibrancy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, Theme.spacingXS)

                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Accent Color")
                            .font(.subheadline)
                        HStack(spacing: Theme.spacingMD) {
                            ForEach(Theme.goalColorOptions.prefix(5), id: \.name) { option in
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                accentPreference == option.name ? Color.primary : Color.clear,
                                                lineWidth: 3
                                            )
                                            .padding(2)
                                    )
                                    .onTapGesture { accentPreference = option.name }
                            }
                        }
                    }
                    .padding(.vertical, Theme.spacingXS)
                }

                // Task Defaults
                Section("Task Defaults") {
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        Text("Default Priority")
                            .font(.subheadline)
                        HStack(spacing: Theme.spacingSM) {
                            ForEach(TaskPriority.allCases) { priority in
                                Button(action: { defaultPriority = priority.rawValue }) {
                                    Label(priority.rawValue, systemImage: priority.icon)
                                        .font(.caption.bold())
                                        .padding(.horizontal, Theme.spacingMD)
                                        .padding(.vertical, Theme.spacingSM)
                                        .background(
                                            defaultPriority == priority.rawValue
                                            ? Theme.priorityColor(priority)
                                            : Theme.priorityColor(priority).opacity(0.15)
                                        )
                                        .foregroundColor(
                                            defaultPriority == priority.rawValue
                                            ? .white
                                            : Theme.priorityColor(priority)
                                        )
                                        .cornerRadius(Theme.cornerLG)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, Theme.spacingXS)
                }

                // Categories
                Section("Categories") {
                    Button(action: { showCategorySheet = true }) {
                        HStack {
                            Label("Manage Categories", systemImage: "tag.fill")
                            Spacer()
                            Text("\(storage.categories.count)")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Bonanova")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Storage")
                        Spacer()
                        Text("\(storage.tasks.count) tasks · \(storage.goals.count) goals")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }

                // Onboarding
                Section {
                    Button(action: { showResetOnboardingConfirm = true }) {
                        Label("View Onboarding Again", systemImage: "arrow.counterclockwise")
                    }
                }

                // Danger zone
                Section {
                    Button(role: .destructive, action: { showResetConfirm = true }) {
                        Label("Delete All Data", systemImage: "trash.fill")
                            .foregroundColor(Theme.urgent)
                    }
                } footer: {
                    Text("This will permanently delete all tasks, goals, and categories.")
                        .font(.caption)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                }
            }
            .alert("Delete All Data?", isPresented: $showResetConfirm) {
                Button("Delete", role: .destructive) {
                    storage.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All tasks, goals, and categories will be permanently deleted.")
            }
            .alert("Reset Onboarding?", isPresented: $showResetOnboardingConfirm) {
                Button("Reset", role: .destructive) {
                    hasOnboarded = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will see the onboarding flow again next time you launch the app.")
            }
            .sheet(isPresented: $showCategorySheet) {
                CategoryManagerView()
                    .environmentObject(storage)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Category Manager

struct CategoryManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storage: PlannerStorageService
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newColorName = "Action_Primary"

    var body: some View {
        NavigationView {
            List {
                ForEach(storage.categories) { cat in
                    HStack(spacing: Theme.spacingMD) {
                        Circle()
                            .fill(Theme.namedColor(cat.colorName))
                            .frame(width: 16, height: 16)
                        Text(cat.name)
                        Spacer()
                        Text("\(storage.tasks.filter { $0.categoryId == cat.id }.count) tasks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { offsets in
                    offsets.forEach {
                        storage.deleteCategory(id: storage.categories[$0].id)
                    }
                }

                if showAddCategory {
                    VStack(alignment: .leading, spacing: Theme.spacingMD) {
                        TextField("Category name", text: $newCategoryName)
                            .submitLabel(.done)
                            .onSubmit { saveCategory() }

                        HStack(spacing: Theme.spacingMD) {
                            ForEach(Theme.goalColorOptions.prefix(5), id: \.name) { opt in
                                Circle()
                                    .fill(opt.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(newColorName == opt.name ? Color.primary : Color.clear, lineWidth: 2)
                                            .padding(2)
                                    )
                                    .onTapGesture { newColorName = opt.name }
                            }
                            Spacer()
                            Button("Save", action: saveCategory)
                                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding(.vertical, Theme.spacingXS)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory.toggle() }) {
                        Image(systemName: showAddCategory ? "minus" : "plus")
                    }
                }
            }
        }
    }

    private func saveCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        storage.addCategory(TaskCategory(name: name, colorName: newColorName))
        newCategoryName = ""
        newColorName = "Action_Primary"
        showAddCategory = false
    }
}
