import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        window.tintColor = UIColor(named: "teal")
        
        let teamsURL = URL.userDocuments.appendingPathComponent("teams")
        
        let resource = LocalFileResource(url: teamsURL, queue: .io)
        
        let store = LocalStore<Team>(resource: resource)
        
        let viewController = TeamsListViewController(store: store)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        
        return true
    }

}


extension DispatchQueue {
    
    static let io = DispatchQueue(label: "IO")
}

extension URL {
    
    static let userDocuments: URL = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: path)
    }()
    
}
