import Foundation
import Combine
import SwiftUI

class PlannerStorageService: ObservableObject {
    @Published var tasks: [PlannerTask] = []
    @Published var goals: [Goal] = []
    @Published var categories: [TaskCategory] = []

    private let tasksKey = "bonanova_tasks"
    private let goalsKey = "bonanova_goals"
    private let categoriesKey = "bonanova_categories"

    init() {
        load()
        if categories.isEmpty {
            categories = TaskCategory.defaultCategories
            saveCategories()
        }
    }

    // MARK: - Tasks

    func addTask(_ task: PlannerTask) {
        tasks.append(task)
        saveTasks()
    }

    func updateTask(_ task: PlannerTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx] = task
        saveTasks()
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        saveTasks()
    }

    func toggleTaskCompletion(id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].isCompleted.toggle()
        saveTasks()
    }

    func tasksFor(date: Date) -> [PlannerTask] {
        tasks
            .filter { DateHelper.shared.isSameDay($0.date, date) }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    func tasksFor(date: Date, slot: TimeSlot) -> [PlannerTask] {
        tasksFor(date: date).filter { $0.timeSlot == slot }
    }

    func moveTasks(slot: TimeSlot, date: Date, from source: IndexSet, to destination: Int) {
        var slotTasks = tasksFor(date: date, slot: slot)
        slotTasks.move(fromOffsets: source, toOffset: destination)
        for (index, var task) in slotTasks.enumerated() {
            task.sortOrder = index
            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[idx] = task
            }
        }
        saveTasks()
    }

    // MARK: - Goals

    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }

    func updateGoal(_ goal: Goal) {
        guard let idx = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[idx] = goal
        saveGoals()
    }

    func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
        saveGoals()
    }

    // MARK: - Categories

    func addCategory(_ category: TaskCategory) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        tasks = tasks.map { task in
            var t = task
            if t.categoryId == id { t.categoryId = nil }
            return t
        }
        saveCategories()
        saveTasks()
    }

    // MARK: - Reset

    func deleteAllData() {
        tasks = []
        goals = []
        categories = TaskCategory.defaultCategories
        saveTasks()
        saveGoals()
        saveCategories()
    }

    // MARK: - Persistence

    private func load() {
        tasks = decode([PlannerTask].self, forKey: tasksKey) ?? []
        goals = decode([Goal].self, forKey: goalsKey) ?? []
        categories = decode([TaskCategory].self, forKey: categoriesKey) ?? []
    }

    private func saveTasks() {
        encode(tasks, forKey: tasksKey)
    }

    private func saveGoals() {
        encode(goals, forKey: goalsKey)
    }

    private func saveCategories() {
        encode(categories, forKey: categoriesKey)
    }

    private func encode<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
