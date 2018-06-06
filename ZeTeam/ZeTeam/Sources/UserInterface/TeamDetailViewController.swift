import UIKit
import RxSwift

enum EditState {
    case editing
    case notEditing
}

struct TeamMember: Codable {
    var name: String
}

class TeamDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var editableDescription: UITextView!
    var labelDescription: UILabel!
    let bag = DisposeBag()
    
    let editableState: BehaviorSubject<EditState>
    
    let memberStore: LocalStore<TeamMember>
    
    var tableView: UITableView?
    
    private var memeberHandles: [Handle<TeamMember>] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    init() {
        
        memeberHandles = []
        editableState = BehaviorSubject(value: .notEditing)
        
        let teamsURL = URL.userDocuments.appendingPathComponent("teamMembers")
        let resource = LocalFileResource(url: teamsURL, queue: .io)
        let store = LocalStore<TeamMember>(resource: resource)
        memberStore = store
        
        super.init(nibName: nil, bundle: nil)
        memberStore.handles.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] memebers in
            self?.memeberHandles = memebers
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let editButton = makeEditButton()
        let saveButton = makeSaveButton()
        
        makeDescription()
        makeTeamMembersSection()
        
        //        editableState.subscribe(onNext: { (state) in
        //            switch state {
        //            case .editing:
        //                self.editableDescription.isHidden = false
        //                self.editableDescription.becomeFirstResponder()
        //                self.labelDescription.isHidden = true
        //                self.navigationItem.rightBarButtonItem = saveButton
        //            case .notEditing:
        //                self.editableDescription.isHidden = true
        //                self.labelDescription.isHidden = false
        //                self.navigationItem.rightBarButtonItem = editButton
        //            }
        //        }).disposed(by: bag)
        
        let isEditing = editableState.map { (state) -> Bool in
            return state == .editing
        }
        
        let activeButton = editableState.map { (state) -> UIBarButtonItem in
            switch state {
            case .editing:
                return saveButton
            case .notEditing:
                return editButton
            }
        }
        
        isEditing.bind(to: labelDescription.rx.isHidden).disposed(by: bag)
        isEditing.map{ !$0 }.bind(to: editableDescription.rx.isHidden).disposed(by: bag)
        activeButton.subscribe(onNext: { (button) in
            self.navigationItem.rightBarButtonItem = button
        }).disposed(by: bag)
        
        editableState.subscribe(onNext: { (state) in
            switch state {
            case .editing:
                self.editableDescription.becomeFirstResponder()
            case .notEditing:
                self.editableDescription.resignFirstResponder()
            }
        }).disposed(by: bag)
        
    }
    
    private func makeEditButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.editableState.onNext(.editing)
        }).disposed(by: bag)
        
        return button
    }
    
    private func makeSaveButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.editableState.onNext(.notEditing)
        }).disposed(by: bag)
        
        return button
    }
    
    private func makeDescription(){
        labelDescription = UILabel()
        
        labelDescription.sizeToFit()
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        labelDescription.numberOfLines = 0
        labelDescription.font = UIFont.systemFont(ofSize: 16)
        let fakeText = "Lorem ipsum dolor sit amet consectetur adipiscing elit vel dis enim elementum et, semper ornare duis felis urna magnis donec proin accumsan erat purus. Lobortis risus ac torquent litora hendrerit massa suspendisse ultricies, integer nunc velit penatibus orci at sollicitudin turpis, eleifend ut ultrices aliquam feugiat tempor congue. Nisl per himenaeos curae justo ligula varius montes tincidunt ridiculus venenatis, pretium porttitor odio sem eget cras lacus maecenas phasellus, senectus sociosqu eu vulputate nulla facilisi blandit bibendum conubia. Malesuada parturient leo est cum class ante morbi hac, consequat quis iaculis ad lacinia condimentum inceptos, tristique convallis nam platea etiam potenti sociis."
        
        labelDescription.text = fakeText
        //label.text = "Team Page Description"
        labelDescription.accessibilityLabel = "teamDescription"
        
        view.addSubview(labelDescription)
        NSLayoutConstraint.activate([
            labelDescription.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
            labelDescription.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            labelDescription.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            ]
        )
        
        editableDescription = UITextView()
        editableDescription.text = fakeText
        editableDescription.accessibilityLabel = "teamDescriptionEdit"
        editableDescription.isHidden = true
        editableDescription.translatesAutoresizingMaskIntoConstraints = false
        editableDescription.font = UIFont.systemFont(ofSize: 16)
        
        view.addSubview(editableDescription)
        
        NSLayoutConstraint.activate([
            editableDescription.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
            editableDescription.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            editableDescription.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            ]
        )
        editableDescription.sizeToFit()
        editableDescription.isScrollEnabled = false
        editableDescription.layer.borderColor = UIColor.gray.cgColor
        editableDescription.layer.borderWidth = 1
        
    }
    
    private func makeTeamMembersSection(){
        let addTeamMemberButton = UIButton()
        addTeamMemberButton.setTitle("Add Team Member", for: .normal)
        addTeamMemberButton.setTitleColor(.gray, for: .normal)
        addTeamMemberButton.translatesAutoresizingMaskIntoConstraints = false
        addTeamMemberButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let s = self else { return }
            
            let alertController = UIAlertController(
                title: "Add Team Member",
                message: nil,
                preferredStyle: .alert
            )
            
            alertController.addTextField(configurationHandler: { textField in
                textField.autocapitalizationType = .words
                textField.accessibilityLabel = "Name"
            })
            
            let textField = alertController.textFields![0]
            
            let name = textField.rx.text
                .map { $0 ?? "" }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .share(replay: 1, scope: .whileConnected)
            
            let create = UIAlertAction(title: "Create", style: .default, handler: { _ in
                name.take(1).subscribe(onNext: { name in
                    let member = TeamMember(name: name)
                    s.memberStore.add(member)
                    //store.add(team)
                }).dispose()
            })
            
            name.map { !$0.isEmpty }.bind(to: create.rx.isEnabled).disposed(by: s.bag)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
            
            alertController.addAction(create)
            alertController.addAction(cancel)
            
            s.present(alertController, animated: true, completion: nil)
        }).disposed(by: bag)
        
        view.addSubview(addTeamMemberButton)
        
        NSLayoutConstraint.activate([
            addTeamMemberButton.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 20),
            addTeamMemberButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addTeamMemberButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addTeamMemberButton.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        let table = UITableView()
        view.addSubview(table)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "member")
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: addTeamMemberButton.bottomAnchor, constant: 20),
            table.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 20)
            ])
        
        table.delegate = self
        table.dataSource = self
        tableView = table
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeberHandles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "member") {
            cell.textLabel?.text = memeberHandles[indexPath.row].content.name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        memeberHandles[indexPath.row].delete()
    }
}
