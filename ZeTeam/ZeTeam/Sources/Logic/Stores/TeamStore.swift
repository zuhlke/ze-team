import Foundation
import RxSwift

final class TeamStore {
    
    private let storage: Observable<Storage>
    
    init(resource: WritableResource) {
        storage = resource.data.map { data in
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
    
    var teams: Observable<[Handle<Team>]> {
        return storage.flatMapLatest { $0.teams }
    }
    
    func add(_ team: Team) {
        // The fact that the data loading and saving is done asynchronously is implementation detail,
        // so the caller should be free to release the store even if in reality it still hasn’t flushed all of its write operations.
        // That’s why we don’t bag the disposable.
        _ = storage.subscribe(onNext: { storage in
            storage.addSubject.onNext(Handle(content: team))
        })
    }
    
    private struct Storage {
        let teams: Observable<[Handle<Team>]>
        let addSubject = PublishSubject<Handle<Team>>()
        let bag = DisposeBag()
        
        init(initialTeams: [Handle<Team>], update: @escaping ([Handle<Team>]) -> Void) {
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
        var teams: [Handle<Team>]
    }
    
}
