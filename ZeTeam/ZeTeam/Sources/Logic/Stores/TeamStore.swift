import Foundation
import RxSwift

final class TeamStore {
    
    private let storage: Observable<Storage>
    
    init(resource: WritableResource) {
        storage = resource.data.map { data in
            let initialTeams = data.flatMap { data in
                return try? JSONDecoder().decode(Teams.self, from: data).contents
            }
            
            return Storage(initialTeams: initialTeams ?? [], update: { teams in
                if let data = try? JSONEncoder().encode(Teams(contents: teams)) {
                    resource.write(data)
                }
            })
        }.share(replay: 1, scope: .forever)
    }
    
    var teams: Observable<[Handle<Team>]> {
        return storage.flatMapLatest { storage in
            storage.teams.map { teams in
                teams.map { Handle(content: $0.content) }
            }
        }
    }
    
    func add(_ team: Team) {
        // The fact that the data loading and saving is done asynchronously is implementation detail,
        // so the caller should be free to release the store even if in reality it still hasn’t flushed all of its write operations.
        // That’s why we don’t bag the disposable.
        _ = storage.subscribe(onNext: { storage in
            storage.addSubject.onNext(Wrapper(content: team))
        })
    }
    
    private struct Storage {
        let teams: Observable<[Wrapper<Team>]>
        let addSubject = PublishSubject<Wrapper<Team>>()
        let bag = DisposeBag()
        
        init(initialTeams: [Wrapper<Team>], update: @escaping ([Wrapper<Team>]) -> Void) {
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
    
    private struct Wrapper<Content: Codable>: Codable {
        var content: Content
    }
    
    private struct Teams: Codable {
        var contents: [Wrapper<Team>]
    }
    
}
