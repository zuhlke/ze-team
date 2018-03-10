import UIKit

final class TeamsListViewController: UIViewController {
    
    override func loadView() {
        let view = UILabel()
        view.text = "Welcome to ZeTeam!"
        view.backgroundColor = .white
        view.textAlignment = .center
        self.view = view
    }
    
}
