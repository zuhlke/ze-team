import Foundation
import RxSwift

final class TeamStore {
    
    private let _storage: Observable<Storage>
    
    init(resource: WritableResource) {
        _storage = resource.data.map { data in
            let initialTeams = data.flatMap { data in
                return try? JSONDecoder().decode(Teams.self, from: data).teams
            }
            
            return Storage(initialTeams: initialTeams ?? [], update: { teams in
                if let data = try? JSONEncoder().encode(Teams(teams: teams)) {
                    resource.write(data)
                }
            })
        }.share(replay: 1, scope: .forever)
    }
    
    var teams: Observable<[Team]> {
        return _storage.flatMapLatest { $0.teams }
    }
    
    func add(_ team: Team) {
        _ = _storage.subscribe(onNext: { storage in
            storage.addSubject.onNext(team)
        })
    }
    
    private struct Storage {
        let teams: Observable<[Team]>
        let addSubject = PublishSubject<Team>()
        let bag = DisposeBag()
        
        init(initialTeams: [Team], update: @escaping ([Team]) -> Void) {
            teams = addSubject
                .scan(initialTeams) { teams, team in
                    var current = teams
                    current.append(team)
                    return current
                }
                .startWith(initialTeams)
                .share(replay: 1, scope: .forever)
            teams.skip(1)
                .subscribe(onNext: update)
                .disposed(by: bag)
        }
    }
    
    private struct Teams: Codable {
        var teams: [Team]
    }
    
}
