import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        window.tintColor = UIColor(named: "teal")
        
        let viewController = TeamsListViewController(teams: [
            Team(name: "Mobile"),
            Team(name: "Site Reliability Engineering"),
            ])
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        
        return true
    }

}

