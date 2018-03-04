import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        window.tintColor = UIColor(named: "teal")
        
        let viewController = UIViewController()
        let view = UILabel()
        view.text = "Welcome to ZeTeam!"
        view.backgroundColor = .white
        view.textAlignment = .center
        viewController.view = view
        window.rootViewController = viewController
        
        return true
    }

}

