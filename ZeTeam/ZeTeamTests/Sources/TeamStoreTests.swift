import XCTest
import RxSwift
@testable import ZeTeam

private final class TestResource: WritableResource {
    var data: Data?
    
    init(data: Data?) {
        self.data = data
    }
    
    func read() -> Observable<Data?> {
        return Observable.just(data)
    }
    
    func write(_ data: Data) -> Observable<Void> {
        self.data = data
        return Observable.empty()
    }
    
}

class TeamStoreTests: XCTestCase {
    
    func testThatTeamsListIsEmptyWhenFileIsEmpty() {
        let store = TeamStore(resource: TestResource(data: nil))
        
        XCTAssert(snapshotsOf: store.teams, match: [
            .next([])
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatTeamsListIsEmptyWhenFileIsCorrupt() {
        let store = TeamStore(resource: TestResource(data: "not valid data".data(using: .utf8)))
        
        XCTAssert(snapshotsOf: store.teams, match: [
            .next([])
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatAddedTeamsAreAppendedToTheList() {
        let teams = (0..<1).map {
            return Team(name: "\($0)")
        }
        
        let store = TeamStore(resource: TestResource(data: nil))
        
        teams.enumerated().forEach { index, team in
            store.add(team)
            XCTAssert(snapshotsOf: store.teams, match: [
                .next(Array(teams.prefix(index+1)))
                ], options: [.doNotWaitForTermination])
        }
    }
    
}
