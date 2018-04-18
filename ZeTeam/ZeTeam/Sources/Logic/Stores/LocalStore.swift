import Foundation
import RxSwift

final class LocalStore<Content: Codable> {
    
    private let storage: Observable<Storage>
    private let updateScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    init(resource: WritableResource) {
        storage = resource.data.map { data in
            let initialState = data.flatMap { data in
                return try? JSONDecoder().decode(State.self, from: data)
            } ?? State()
            
            return Storage(initialState: initialState, update: { state in
                if let data = try? JSONEncoder().encode(state) {
                    resource.write(data)
                }
            })
        }.share(replay: 1, scope: .forever)
    }
    
    var handles: Observable<[Handle<Content>]> {
        return storage.flatMapLatest { storage in
            storage.state.map { contents in
                contents.contents.map { wrapper in
                    Handle(content: wrapper.content) {
                        self.deleteTeam(withIdentifier: wrapper.identifier)
                    }
                }
            }
        }
    }
    
    func add(_ content: Content) {
        update { contents in
            contents.add(content)
        }
    }
    
    private func deleteTeam(withIdentifier identifier: SequentialIdentifier) {
        update { contents in
            contents.deleteTeam(withIdentifier: identifier)
        }
    }
    
    private func update(using mutate: @escaping (inout State) -> Void) {
        // The fact that the data loading and saving is done asynchronously is implementation detail,
        // so the caller should be free to release the store even if in reality it still hasn’t flushed all of its write operations.
        // That’s why we don’t bag the disposable.
        _ = storage.subscribe(onNext: { storage in
            var contents = try! storage.state.value()
            mutate(&contents)
            storage.state.onNext(contents)
        })
    }
    
    private struct Storage {
        let state: BehaviorSubject<State>
        let bag = DisposeBag()
        
        var currentTeams: State {
            return try! state.value()
        }
        
        init(initialState: State, update: @escaping (State) -> Void) {
            state = BehaviorSubject<State>(value: initialState)
            
            state.skip(1)
                .subscribe(onNext: update)
                .disposed(by: bag)
        }
    }
    
    private struct Wrapper<Content: Codable>: Codable {
        var content: Content
        var identifier: SequentialIdentifier
    }
    
    private struct State: Codable {
        var contents: [Wrapper<Content>]
        var nextIdentifier: SequentialIdentifier
        
        init(contents: [Wrapper<Content>] = [], nextIdentifier: SequentialIdentifier = .initial) {
            self.contents = contents
            self.nextIdentifier = nextIdentifier
        }
        
        mutating func add(_ content: Content) {
            contents.append(Wrapper(content: content, identifier: nextIdentifier))
            nextIdentifier = nextIdentifier.next()
        }
        
        mutating func deleteTeam(withIdentifier identifier: SequentialIdentifier) {
            contents = contents.filter { $0.identifier != identifier }
        }
    }
    
}
