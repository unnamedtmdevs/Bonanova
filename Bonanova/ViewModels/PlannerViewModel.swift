import Foundation
import Combine

class PlannerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var showAddTask: Bool = false
    @Published var editingTask: PlannerTask?
    @Published var filterCategory: UUID? = nil

    private let storage: PlannerStorageService
    private var cancellables = Set<AnyCancellable>()

    init(storage: PlannerStorageService) {
        self.storage = storage
        storage.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Queries

    func tasks(for slot: TimeSlot) -> [PlannerTask] {
        var result = storage.tasksFor(date: selectedDate, slot: slot)
        if let catId = filterCategory {
            result = result.filter { $0.categoryId == catId }
        }
        return result
    }

    func allTasksForSelectedDate() -> [PlannerTask] {
        storage.tasksFor(date: selectedDate)
    }

    func urgentTasksForToday() -> [PlannerTask] {
        storage.tasks.filter {
            DateHelper.shared.isSameDay($0.date, Date()) &&
            $0.priority == .urgent &&
            !$0.isCompleted
        }
    }

    func completionRate(for date: Date) -> Double {
        let tasks = storage.tasksFor(date: date)
        guard !tasks.isEmpty else { return 0 }
        return Double(tasks.filter { $0.isCompleted }.count) / Double(tasks.count)
    }

    func taskDensity(for date: Date) -> Int {
        storage.tasks.filter { DateHelper.shared.isSameDay($0.date, date) }.count
    }

    func categoryFor(id: UUID?) -> TaskCategory? {
        guard let id else { return nil }
        return storage.categories.first { $0.id == id }
    }

    var categories: [TaskCategory] { storage.categories }

    // MARK: - Mutations

    func addTask(title: String, notes: String, slot: TimeSlot, priority: TaskPriority, categoryId: UUID?) {
        let count = storage.tasksFor(date: selectedDate, slot: slot).count
        let task = PlannerTask(
            title: title,
            notes: notes,
            date: selectedDate,
            timeSlot: slot,
            priority: priority,
            categoryId: categoryId,
            sortOrder: count
        )
        storage.addTask(task)
    }

    func updateTask(_ task: PlannerTask) {
        storage.updateTask(task)
    }

    func toggleCompletion(task: PlannerTask) {
        storage.toggleTaskCompletion(id: task.id)
    }

    func deleteTask(_ task: PlannerTask) {
        storage.deleteTask(id: task.id)
    }

    func deleteTasks(slot: TimeSlot, at offsets: IndexSet) {
        let slotTasks = tasks(for: slot)
        offsets.forEach { storage.deleteTask(id: slotTasks[$0].id) }
    }

    func moveTasks(slot: TimeSlot, from source: IndexSet, to destination: Int) {
        storage.moveTasks(slot: slot, date: selectedDate, from: source, to: destination)
    }

    // MARK: - Stats

    func todayStats() -> DailyStats {
        AnalyticsService.dailyStats(tasks: storage.tasks, for: Date())
    }

    func weeklyStats() -> WeeklyStats {
        AnalyticsService.weeklyStats(tasks: storage.tasks, for: selectedDate)
    }
}
