import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogAssembly().build()
        catalogController.title = NSLocalizedString("Tab.catalog", comment: "")
        let catalogNavigation = UINavigationController(rootViewController: catalogController)
        catalogNavigation.tabBarItem = catalogTabBarItem

        viewControllers = [catalogNavigation]

        view.backgroundColor = .systemBackground
    }
}
