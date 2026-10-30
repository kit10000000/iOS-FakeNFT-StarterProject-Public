import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )

    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(resource: .basket),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogAssembly(servicesAssembly: servicesAssembly).build()
        catalogController.title = NSLocalizedString("Tab.catalog", comment: "")
        let catalogVC = UINavigationController(rootViewController: catalogController)
        catalogVC.tabBarItem = catalogTabBarItem
        
        let cartController = CartAssembly(servicesAssembler: servicesAssembly).build()
        let cartVC = UINavigationController(rootViewController: cartController)
        cartVC.tabBarItem = cartTabBarItem

        viewControllers = [catalogVC, cartVC]

        view.backgroundColor = .systemBackground
    }
}
