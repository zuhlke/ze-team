import UIKit

final class TeamsListViewController: UITableViewController {
    
    private let teams: [Team]
    private let cellReuseIdentifier = UUID().uuidString
    
    init(teams: [Team]) {
        self.teams = teams
        super.init(nibName: nil, bundle: nil)
        self.title = "Teams"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = teams[indexPath.row].name
        return cell
    }
    
}
