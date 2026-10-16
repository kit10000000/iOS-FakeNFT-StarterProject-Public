import UIKit

struct ErrorModel {
    let message: String
    let actionText: String
    let action: () -> Void
    var cancelText: String? = nil
    var cancelAction: (() -> Void)? = nil
}

protocol ErrorView {
    func showError(_ model: ErrorModel)
}

extension ErrorView where Self: UIViewController {

    func showError(_ model: ErrorModel) {
        let title = NSLocalizedString("Error.title", comment: "")
        let alert = UIAlertController(
            title: title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.actionText, style: UIAlertAction.Style.default) {_ in
            model.action()
        }
        alert.addAction(action)
        
        if let cancelText = model.cancelText {
            alert.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in model.cancelAction?() })
        }
        present(alert, animated: true)
    }
}
