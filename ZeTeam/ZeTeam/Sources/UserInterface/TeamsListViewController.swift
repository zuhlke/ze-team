import UIKit
import RxSwift
import RxCocoa

final class TeamsListViewController: UITableViewController {
    
    private let cellReuseIdentifier = UUID().uuidString
    private let bag = DisposeBag()
    
    private var teams: [Team] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(store: TeamStore) {
        self.teams = []
        super.init(nibName: nil, bundle: nil)
        self.title = "Teams"
        
        store.teams.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] teams in
            self?.teams = teams
        }).disposed(by: bag)
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
