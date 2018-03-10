import Foundation
import RxSwift

final class TeamStore {
    
    private let _teams = BehaviorSubject<[Team]>(value: [])
    
    init(resource: WritableResource) {
        
    }
    
    var teams: Observable<[Team]> {
        return _teams
    }
    
    func add(_ team: Team) {
        var current = try! _teams.value()
        current.append(team)
        _teams.onNext(current)
    }
    
}
