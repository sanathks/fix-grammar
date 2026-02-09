import Foundation

enum PopupPhase {
    case loading
    case result(String)
    case error(String)
}

final class PopupState: ObservableObject {
    @Published var phase: PopupPhase
    @Published var selectedModeId: UUID?

    var modes: [RewriteMode]
    var onModeSelected: ((RewriteMode) -> Void)?
    var onReplace: ((String) -> Void)?
    var onCopy: ((String) -> Void)?
    var onCancel: (() -> Void)?

    init(modes: [RewriteMode]) {
        self.modes = modes
        self.phase = .loading
    }
}
