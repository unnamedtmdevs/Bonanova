import Foundation

struct TaskCategory: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var colorName: String
    var createdAt: Date = Date()

    static func == (lhs: TaskCategory, rhs: TaskCategory) -> Bool {
        lhs.id == rhs.id
    }
}

extension TaskCategory {
    static let defaultCategories: [TaskCategory] = [
        TaskCategory(name: "Work", colorName: "Action_Primary"),
        TaskCategory(name: "Personal", colorName: "Action_Creative"),
        TaskCategory(name: "Health", colorName: "Action_Success"),
        TaskCategory(name: "Urgent", colorName: "Action_Urgent")
    ]
}
