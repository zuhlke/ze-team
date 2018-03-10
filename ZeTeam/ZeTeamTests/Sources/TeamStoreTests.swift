import XCTest
import RxSwift
@testable import ZeTeam

private struct TestResource: WritableResource {
    var data: Data?
    
    func read() -> Observable<Data?> {
        return Observable.just(data)
    }
    
    func write(_ data: Data) -> Observable<Void> {
        return Observable.empty()
    }
    
}

class TeamStoreTests: XCTestCase {
    
    func testThatTeamsListIsEmptyWhenFileIsEmpty() {
        let store = TeamStore(resource: TestResource(data: nil))
        
        XCTAssert(snapshotsOf: store.teams, match: [
            .next([])
            ])
    }
    
}
