//
//  SceneDelegate.swift
//  ProxDeals
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Keeps the Cart tab badge correct app-wide, even before the
    /// Cart screen has been opened for the first time.
    private var badgeManager: CartBadgeManager?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        // The storyboard sets up the window + tab bar automatically.
        // Once it exists, hand the tab bar to a badge manager.
        if let tabBar = window?.rootViewController as? UITabBarController {
            badgeManager = CartBadgeManager(tabBarController: tabBar)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

/// Watches SaveStore and updates the Cart tab badge.
/// The Cart tab is identified by its tabBarItem title ("Cart").
final class CartBadgeManager {
    private weak var tabBarController: UITabBarController?

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        NotificationCenter.default.addObserver(
            self, selector: #selector(update),
            name: SaveStore.didChangeNotification, object: nil)
        update()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func update() {
        guard let items = tabBarController?.tabBar.items else { return }
        let cartItem = items.first { $0.title == "Cart" }
        let count = SaveStore.shared.count
        cartItem?.badgeValue = count > 0 ? "\(count)" : nil
    }
}
