import Foundation

final class PopupState: ObservableObject {
    let title: String

    @Published var isLoading = true
    @Published var resultText = ""
    @Published var errorMessage: String?

    var onReplace: ((String) -> Void)?
    var onCopy: ((String) -> Void)?
    var onCancel: (() -> Void)?

    init(title: String) {
        self.title = title
    }
}
