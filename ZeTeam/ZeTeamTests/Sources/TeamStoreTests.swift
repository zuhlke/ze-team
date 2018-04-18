import XCTest
import RxSwift
@testable import ZeTeam

class LocalStoreTests: XCTestCase {
    
    func testThatResourceIsNeverReadIfNotNecessary() {
        let resource = TestResource(data: nil)
        _ = LocalStore<Team>(resource: resource)
        
        XCTAssertEqual(resource.readCount, 0)
    }
    
    func testThatResourceIsReadAtMostOnce() {
        let resource = TestResource(data: nil)
        let store = LocalStore<Team>(resource: resource)
        _ = store.handles.subscribe()
        _ = store.handles.subscribe()
        
        XCTAssertEqual(resource.readCount, 1)
    }
    
    func testThatContentsListIsEmptyWhenFileIsEmpty() {
        let store = LocalStore<Team>(resource: TestResource(data: nil))
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next([])
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatContentsListIsEmptyWhenFileIsCorrupt() {
        let store = LocalStore<Team>(resource: TestResource(data: "not valid data".data(using: .utf8)))
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next([])
            ], options: [.doNotWaitForTermination])
    }
    
    func testThatAddedContentsAreAppendedToTheList() {
        let teams = (0..<4).map {
            return Team(name: "\($0)")
        }
        
        let store = LocalStore<Team>(resource: TestResource(data: nil))
        
        teams.enumerated().forEach { index, team in
            store.add(team)
            XCTAssert(snapshotsOf: store.contents, match: [
                .next(Array(teams.prefix(index+1)))
                ], options: [.doNotWaitForTermination])
        }
    }
    
    func testThatAddedContentsAreStored() {
        let teams = [Team(name: "78"), Team(name: "90")]
        
        let resource = TestResource(data: nil)
        teams.forEach { team in
            let store1 = LocalStore<Team>(resource: resource)
            store1.add(team)
        }
        
        let store2 = LocalStore<Team>(resource: resource)
        
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
            let store = LocalStore<Team>(resource: resource)
            store.add(Team(name: "any"))
        }
        
        resource.dataToRead.onNext(nil)
        XCTAssertNotNil(resource.wroteData)
    }
    
    func testDeletingAcrossSerialization() {
        var teams = (0..<4).map {
            return Team(name: "\($0)")
        }
        
        let resource = TestResource(data: nil)
        let store = LocalStore<Team>(resource: resource)
        
        teams.forEach(store.add)
        
        let indexToDelete = 2
        store.handles.take(1).subscribe(onNext: { teamHandles in
            teamHandles[indexToDelete].delete()
        }).dispose()
        
        teams.remove(at: indexToDelete)
        
        let store2 = LocalStore<Team>(resource: resource)
        
        XCTAssert(snapshotsOf: store2.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
    func testDeletingContents() {
        var teams = (0..<4).map {
            return Team(name: "\($0)")
        }
        
        let store = LocalStore<Team>(resource: TestResource(data: nil))
        
        teams.forEach(store.add)
        
        let indexToDelete = 2
        store.handles.take(1).subscribe(onNext: { teamHandles in
            teamHandles[indexToDelete].delete()
        }).dispose()
        
        teams.remove(at: indexToDelete)
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
    func testDeletingTeamASecondTypeIsNoOp() {
        var teams = (0..<4).map {
            return Team(name: "\($0)")
        }
        
        let store = LocalStore<Team>(resource: TestResource(data: nil))
        
        teams.forEach(store.add)
        
        let indexToDelete = 2
        var teamToDelete: Handle<Team>?
        store.handles.take(1).subscribe(onNext: { teamHandles in
            teamToDelete = teamHandles[indexToDelete]
            teamToDelete?.delete()
        }).dispose()
        
        teams.remove(at: indexToDelete)
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
        
        teamToDelete?.delete()
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
    func testDeletingTeamASecondTypeIsNoOpEvenAfterANewInsert() {
        var teams = (0..<4).map {
            return Team(name: "\($0)")
        }
        
        let store = LocalStore<Team>(resource: TestResource(data: nil))
        
        teams.forEach(store.add)
        
        let indexToDelete = 2
        var teamToDelete: Handle<Team>?
        store.handles.take(1).subscribe(onNext: { teamHandles in
            teamToDelete = teamHandles[indexToDelete]
            teamToDelete?.delete()
        }).dispose()
        
        teams.remove(at: indexToDelete)
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
        
        let newTeam = Team(name: "5")
        teams.append(newTeam)
        store.add(newTeam)
        teamToDelete?.delete()
        
        XCTAssert(snapshotsOf: store.contents, match: [
            .next(teams)
            ], options: [.doNotWaitForTermination])
    }
    
}

private extension LocalStore {
    
    var contents: Observable<[Content]> {
        return handles.map { $0.map { $0.content } }
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
