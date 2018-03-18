import XCTest
import RxSwift
@testable import ZeTeam

private final class TestResource: WritableResource {
    var _data: Data?
    
    var readDelay: TimeInterval?
    
    var readCount = 0
    var writeCount = 0
    
    init(data: Data?) {
        self._data = data
    }
    
    var data: Observable<Data?> {
        let response = Observable<Data?>.deferred {
            self.readCount += 1
            return Observable.just(self._data)
        }
        if let readDelay = readDelay {
            return response.delay(readDelay, scheduler: MainScheduler.instance)
        } else {
            return response
        }
    }
    
    func write(_ data: Data) {
        writeCount += 1
        self._data = data
    }
    
}

class TeamStoreTests: XCTestCase {
    
    func testThatResourceIsNeverReadIfNotNecessary() {
        let resource = TestResource(data: nil)
        _ = TeamStore(resource: resource)
        
        XCTAssertEqual(resource.readCount, 0)
    }
    
    func testThatResourceIsReadAtMostOnce() {
        let resource = TestResource(data: nil)
        let store = TeamStore(resource: resource)
        _ = store.teams.subscribe()
        _ = store.teams.subscribe()
        
        XCTAssertEqual(resource.readCount, 1)
    }
    
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
        let teams = (0..<4).map {
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
    
    func testThatAddedTeamsAreStored() {
        let teams = [Team(name: "78"), Team(name: "90")]
        
        let resource = TestResource(data: nil)
        teams.forEach { team in
            let store1 = TeamStore(resource: resource)
            store1.add(team)
        }
        
        let store2 = TeamStore(resource: resource)
        
        XCTAssert(snapshotsOf: store2.teams, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
}
