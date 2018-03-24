import XCTest
import RxSwift
@testable import ZeTeam

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
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next([])
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatTeamsListIsEmptyWhenFileIsCorrupt() {
        let store = TeamStore(resource: TestResource(data: "not valid data".data(using: .utf8)))
        
        XCTAssert(snapshotsOf: store.contents, match: [
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
            XCTAssert(snapshotsOf: store.contents, match: [
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
        
        XCTAssert(snapshotsOf: store2.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatPromisedWritesAreFlushedEvenIfStoreIsReleased() {
        
        class Resource: WritableResource {
            var dataToRead = PublishSubject<Data?>()
            var wroteData: Data?
            
            var data: Observable<Data?> {
                return dataToRead
            }
            
            func write(_ data: Data) {
                wroteData = data
            }
        }
        
        let resource = Resource()
        
        do {
            let store = TeamStore(resource: resource)
            store.add(Team(name: "any"))
        }
        
        resource.dataToRead.onNext(nil)
        XCTAssertNotNil(resource.wroteData)
    }
    
}

private extension TeamStore {
    
    var contents: Observable<[Team]> {
        return teams.map { $0.map { $0.content } }
    }
}

private final class TestResource: WritableResource {
    var _data: Data?
    
    var readCount = 0
    var writeCount = 0
    
    init(data: Data?) {
        self._data = data
    }
    
    var data: Observable<Data?> {
        return Observable<Data?>.deferred {
            self.readCount += 1
            return Observable.just(self._data)
        }
    }
    
    func write(_ data: Data) {
        writeCount += 1
        self._data = data
    }
    
}
