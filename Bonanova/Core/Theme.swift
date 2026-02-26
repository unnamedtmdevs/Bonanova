import SwiftUI

enum Theme {
    // MARK: - Background Colors
    static let bgPrimary = Color("BG_Primary")
    static let bgSecondary = Color("BG_Secondary")

    // MARK: - Action Colors
    static let urgent = Color("Action_Urgent")
    static let primary = Color("Action_Primary")
    static let highlight = Color("Action_Highlight")
    static let success = Color("Action_Success")
    static let creative = Color("Action_Creative")

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: - Corner Radii
    static let cornerSM: CGFloat = 8
    static let cornerMD: CGFloat = 12
    static let cornerLG: CGFloat = 16
    static let cornerXL: CGFloat = 24

    // MARK: - Priority Colors
    static func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .urgent: return urgent
        case .normal: return primary
        case .low: return success
        }
    }

    static func namedColor(_ name: String) -> Color {
        Color(name)
    }

    // MARK: - Category Goal Colors
    static let goalColorOptions: [(name: String, color: Color)] = [
        ("Action_Primary", primary),
        ("Action_Urgent", urgent),
        ("Action_Success", success),
        ("Action_Creative", creative),
        ("Action_Highlight", highlight),
        ("BG_Secondary", bgSecondary)
    ]
}
