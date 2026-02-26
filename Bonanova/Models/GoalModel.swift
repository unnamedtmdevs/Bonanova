import Foundation

struct Subtask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
}

struct Goal: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var goalDescription: String = ""
    var subtasks: [Subtask] = []
    var createdAt: Date = Date()
    var targetDate: Date?
    var colorName: String = "Action_Primary"

    var completionRate: Double {
        guard !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    var isCompleted: Bool {
        !subtasks.isEmpty && subtasks.allSatisfy { $0.isCompleted }
    }

    var completedCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }
}
