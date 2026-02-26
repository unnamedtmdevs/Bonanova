import Foundation

enum TimeSlot: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    var colorName: String {
        switch self {
        case .morning: return "Action_Highlight"
        case .afternoon: return "Action_Primary"
        case .evening: return "Action_Creative"
        }
    }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case urgent = "Urgent"
    case normal = "Normal"
    case low = "Low"

    var id: String { rawValue }

    var colorName: String {
        switch self {
        case .urgent: return "Action_Urgent"
        case .normal: return "Action_Primary"
        case .low: return "Action_Success"
        }
    }

    var icon: String {
        switch self {
        case .urgent: return "flame.fill"
        case .normal: return "minus.circle.fill"
        case .low: return "arrow.down.circle.fill"
        }
    }
}

struct PlannerTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String = ""
    var date: Date
    var timeSlot: TimeSlot
    var priority: TaskPriority
    var categoryId: UUID?
    var isCompleted: Bool = false
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    static func == (lhs: PlannerTask, rhs: PlannerTask) -> Bool {
        lhs.id == rhs.id
    }
}
