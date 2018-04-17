import Foundation
import XCTest
import TestingSupport
@testable import ZeTeam

class LocalFileResourceTests: XCTestCase {
    
    private let queue = DispatchQueue(label: "testIO")
    
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    
    override func setUp() {
        super.setUp()
        
        try? FileManager().removeItem(at: url)
    }
    
    override func tearDown() {
        try? FileManager().removeItem(at: url)
        
        super.tearDown()
    }
    
    func testThatInitTrapIfURLIsNotFileURL() {
        let url = URL(string: "http://somewhere.com")!
        XCTAssertFatalError {
            _ = LocalFileResource(url: url, queue: self.queue)
        }
    }
    
    func testThatItReturnsNilIfFileIsMissing() throws {
        let resource = LocalFileResource(url: url, queue: queue)
        
        XCTAssert(snapshotsOf: resource.data, match: [
            .next(nil),
            .completed()
            ], timeOut: .never)
    }
    
    func testThatItReadsFiles() throws {
        let data = "someText".data(using: .utf8)!
        try data.write(to: url)
        let resource = LocalFileResource(url: url, queue: queue)
        
        XCTAssert(snapshotsOf: resource.data, match: [
            .next(data),
            .completed()
            ], timeOut: .never)
    }
    
    func testThatReadErrorsAreConvertedToNil() throws {
        let resource = LocalFileResource(url: URL(fileURLWithPath: "/"), queue: queue)
        
        XCTAssert(snapshotsOf: resource.data, match: [
            .next(nil),
            .completed()
            ], timeOut: .never)
    }
    
    func testThatItWritesFiles() throws {
        let data = "someText".data(using: .utf8)!
        let resource = LocalFileResource(url: url, queue: queue)
        resource.write(data)
        queue.sync {
            let actual = try? Data(contentsOf: self.url)
            XCTAssertEqual(actual, data)
        }
    }
    
}

