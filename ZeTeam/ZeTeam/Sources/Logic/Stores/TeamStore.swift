import Foundation
import RxSwift

final class TeamStore {
    
    private let storage: Observable<Storage>
    private let updateScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    init(resource: WritableResource) {
        storage = resource.data.map { data in
            let initialTeams = data.flatMap { data in
                return try? JSONDecoder().decode(Teams.self, from: data)
            } ?? Teams()
            
            return Storage(initialTeams: initialTeams, update: { teams in
                if let data = try? JSONEncoder().encode(teams) {
                    resource.write(data)
                }
            })
        }.share(replay: 1, scope: .forever)
    }
    
    var teams: Observable<[Handle<Team>]> {
        return storage.flatMapLatest { storage in
            storage.teams.map { teams in
                teams.contents.map { wrapper in
                    Handle(content: wrapper.content) {
                        self.deleteTeam(withIdentifier: wrapper.identifier)
                    }
                }
            }
        }
    }
    
    func add(_ team: Team) {
        update { teams in
            teams.add(team)
        }
    }
    
    private func deleteTeam(withIdentifier identifier: SequentialIdentifier) {
        update { teams in
            teams.deleteTeam(withIdentifier: identifier)
        }
    }
    
    private func update(using mutate: @escaping (inout Teams) -> Void) {
        // The fact that the data loading and saving is done asynchronously is implementation detail,
        // so the caller should be free to release the store even if in reality it still hasn’t flushed all of its write operations.
        // That’s why we don’t bag the disposable.
        _ = storage.subscribe(onNext: { storage in
            var teams = try! storage.teams.value()
            mutate(&teams)
            storage.teams.onNext(teams)
        })
    }
    
    private struct Storage {
        let teams: BehaviorSubject<Teams>
        let bag = DisposeBag()
        
        var currentTeams: Teams {
            return try! teams.value()
        }
        
        init(initialTeams: Teams, update: @escaping (Teams) -> Void) {
            teams = BehaviorSubject<Teams>(value: initialTeams)
            
            teams.skip(1)
                .subscribe(onNext: update)
                .disposed(by: bag)
        }
    }
    
    private struct Wrapper<Content: Codable>: Codable {
        var content: Content
        var identifier: SequentialIdentifier
    }
    
    private struct Teams: Codable {
        var contents: [Wrapper<Team>]
        var nextIdentifier: SequentialIdentifier
        
        init(contents: [Wrapper<Team>] = [], nextIdentifier: SequentialIdentifier = .initial) {
            self.contents = contents
            self.nextIdentifier = nextIdentifier
        }
        
        mutating func add(_ team: Team) {
            contents.append(Wrapper(content: team, identifier: nextIdentifier))
            nextIdentifier = nextIdentifier.next()
        }
        
        mutating func deleteTeam(withIdentifier identifier: SequentialIdentifier) {
            contents = contents.filter { $0.identifier != identifier }
        }
    }
    
}
