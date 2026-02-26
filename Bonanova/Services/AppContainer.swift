import Foundation
import Combine

final class AppContainer: ObservableObject {
    let storage: PlannerStorageService
    let plannerVM: PlannerViewModel
    let goalVM: GoalViewModel

    init() {
        let storage = PlannerStorageService()
        self.storage = storage
        self.plannerVM = PlannerViewModel(storage: storage)
        self.goalVM = GoalViewModel(storage: storage)
    }
}
