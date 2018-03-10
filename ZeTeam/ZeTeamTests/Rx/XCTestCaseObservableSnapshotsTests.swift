import XCTest
import RxSwift

class XCTestCaseObservableSnapshotsTests: XCTestCase {
    
    // MARK: Sync
    
    func testThatAVerifierIsCalledForEachEvent() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        var callbackCount = 0
        var verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
            }
        }
        verifiers.append(.completed {
            callbackCount += 1
            })
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers))
        XCTAssertEqual(callbackCount, 5)
    }
    
    func testThatAVerifierIsCalledForEachEventWithoutWaitingForTermaintaion() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        var callbackCount = 0
        let verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
            }
        }
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers, options: [.doNotWaitForTermination]))
        XCTAssertEqual(callbackCount, 4)
    }
    
    func testThatVerificationFailsIfNotEnoughVerifiers() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: []))
    }
    
    func testThatVerificationFailsIfTooManyVerifiers() {
        let expected = 1
        let observable = Observable.just(expected)
        
        let verifier = SnapshotVerifier<Int>.any()

        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: [verifier, verifier, verifier]))
    }
    
    // MARK: Async
    
    func testThatAVerifierIsCalledForEachAsyncEventWaitingForTermaintaion() {
        let queue = DispatchQueue(label: "Events")
        
        var sharedObserver: AnyObserver<Int>?
        
        let next = { (value: Int) in
            queue.async {
                sharedObserver?.onNext(value)
            }
        }
        
        let observable = Observable<Int>.create { observer in
            sharedObserver = observer
            next(1)
            return Disposables.create()
        }
        
        let elements = [1, 2, 3, 4]
        
        let completed = Variable(false)
        
        var callbackCount = 0
        var verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
                if value < 4 {
                    next(value+1)
                } else {
                    sharedObserver?.onCompleted()
                }
            }
        }
        verifiers.append(.completed {
            callbackCount += 1
            completed.value = true
            })
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers, timeOut: .byChecking(completed)))
        XCTAssertEqual(callbackCount, 5)
    }
    
    func testThatAVerifierIsCalledForEachAsyncEventWithoutWaitingForTermaintaion() {
        let queue = DispatchQueue(label: "Events")
        
        var sharedObserver: AnyObserver<Int>?
        
        let next = { (value: Int) in
            queue.async {
                sharedObserver?.onNext(value)
            }
        }
        
        let observable = Observable<Int>.create { observer in
            sharedObserver = observer
            next(1)
            return Disposables.create()
        }
        
        let elements = [1, 2, 3, 4]
        
        let completed = Variable(false)
        
        var callbackCount = 0
        let verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
                if value < 4 {
                    next(value+1)
                } else {
                    completed.value = true
                }
            }
        }
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers, options: [.doNotWaitForTermination], timeOut: .byChecking(completed)))
        XCTAssertEqual(callbackCount, 4)
    }
    
    func testThatAsyncThrowsIfTimeoutIsZero() {
        let queue = DispatchQueue(label: "Events")
        
        let observable = Observable<Int>.create { observer in
            queue.async {
                observer.onNext(1)
            }
            return Disposables.create()
        }
        
        // we didn’t tell `verify()` to expect async result
        // so it should throw that sequence was not long enough
        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: [.any()]))
    }
    
    func testThatAsyncThrowsIfNotCompletedByDeadlineExpected() {
        let queue = DispatchQueue(label: "Events")
        
        let completed = Variable(false)
        
        let observable = Observable<Int>.create { observer in
            queue.async {
                observer.onCompleted()
                completed.value = true
            }
            return Disposables.create()
        }
        
        // we didn’t tell `verify()` to expect async result
        // so it should throw that sequence was not long enough
        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: [], timeOut: .byChecking(completed)))
    }
    
}
