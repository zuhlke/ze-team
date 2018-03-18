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
        
        self.navigationItem.rightBarButtonItem = makeCreateTeamBarButtonItem(store: store)
    }
    
    private func makeCreateTeamBarButtonItem(store: TeamStore) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        item.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let s = self else { return }
            
            let alertController = UIAlertController(
                title: "Create a New Team",
                message: nil,
                preferredStyle: .alert
            )
            
            alertController.addTextField(configurationHandler: { textField in
                textField.autocapitalizationType = .words
            })
            
            let textField = alertController.textFields![0]
            
            let name = textField.rx.text
                .map { $0 ?? "" }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .share(replay: 1, scope: .whileConnected)
            
            let create = UIAlertAction(title: "Create", style: .default, handler: { _ in
                name.take(1).subscribe(onNext: { name in
                    let team = Team(name: name)
                    store.add(team)
                }).dispose()
            })
            
            name.map { !$0.isEmpty }.bind(to: create.rx.isEnabled).disposed(by: s.bag)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
            })
            
            alertController.addAction(create)
            alertController.addAction(cancel)
            
            s.present(alertController, animated: true, completion: nil)
        }).disposed(by: bag)
        return item
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
