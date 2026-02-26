import Foundation
import Combine

class GoalViewModel: ObservableObject {
    @Published var showAddGoal: Bool = false

    private let storage: PlannerStorageService
    private var cancellables = Set<AnyCancellable>()

    init(storage: PlannerStorageService) {
        self.storage = storage
        storage.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    var goals: [Goal] { storage.goals }

    func addGoal(title: String, description: String, colorName: String, targetDate: Date?) {
        let goal = Goal(
            title: title,
            goalDescription: description,
            targetDate: targetDate,
            colorName: colorName
        )
        storage.addGoal(goal)
    }

    func updateGoal(_ goal: Goal) {
        storage.updateGoal(goal)
    }

    func deleteGoal(_ goal: Goal) {
        storage.deleteGoal(id: goal.id)
    }

    func addSubtask(to goalId: UUID, title: String) {
        guard var goal = storage.goals.first(where: { $0.id == goalId }) else { return }
        goal.subtasks.append(Subtask(title: title))
        storage.updateGoal(goal)
    }

    func toggleSubtask(goalId: UUID, subtaskId: UUID) {
        guard var goal = storage.goals.first(where: { $0.id == goalId }) else { return }
        guard let idx = goal.subtasks.firstIndex(where: { $0.id == subtaskId }) else { return }
        goal.subtasks[idx].isCompleted.toggle()
        storage.updateGoal(goal)
    }

    func deleteSubtask(goalId: UUID, subtaskId: UUID) {
        guard var goal = storage.goals.first(where: { $0.id == goalId }) else { return }
        goal.subtasks.removeAll { $0.id == subtaskId }
        storage.updateGoal(goal)
    }

    func overallProgress() -> Double {
        let all = storage.goals.flatMap { $0.subtasks }
        guard !all.isEmpty else { return 0 }
        return Double(all.filter { $0.isCompleted }.count) / Double(all.count)
    }

    func completedGoalsCount() -> Int {
        storage.goals.filter { $0.isCompleted }.count
    }
}
