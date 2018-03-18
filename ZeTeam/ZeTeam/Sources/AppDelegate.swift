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
        
        struct EmptyResource: WritableResource {
            var data: Observable<Data?> {
                return Observable.just(nil)
            }
            
            func write(_ data: Data) {
                
            }
        }
        
        let store = TeamStore(resource: EmptyResource())
        store.add(Team(name: "Mobile"))
        store.add(Team(name: "Site Reliability Engineering"))
        
        let viewController = TeamsListViewController(store: store)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        
        return true
    }

}

