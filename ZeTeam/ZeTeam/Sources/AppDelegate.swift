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
        
        let initialTeams = [
            Team(name: "Mobile"),
            Team(name: "Site Reliability Engineering"),
            ]
        
        let laterTeams = [
            Team(name: "Mobile"),
            Team(name: "Cloud Computing"),
            ]
        
        let teams = Observable.just(laterTeams)
            .delay(3, scheduler: MainScheduler.instance)
            .startWith(initialTeams)
        
        let viewController = TeamsListViewController(teams: teams)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        
        return true
    }

}

