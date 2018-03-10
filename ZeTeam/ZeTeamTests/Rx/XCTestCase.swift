import XCTest
import RxSwift

extension XCTestCase {
    
    enum SnapshotVerificationOptions {
        case doNotWaitForTermination
    }
    
    func XCTAssert<T>(snapshotsOf observable: T, match verifiers: [SnapshotVerifier<T.E>], options: Set<SnapshotVerificationOptions> = [], timeOut timeout: TimeoutProvider = .immediate, file: StaticString = #file, line: UInt = #line) where T: ObservableConvertibleType {
        do {
            try verify(snapshotsOf: observable, match: verifiers, options: options, timeOut: timeout)
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }
    
    func verify<T>(snapshotsOf observable: T, match verifiers: [SnapshotVerifier<T.E>], options: Set<SnapshotVerificationOptions> = [], timeOut timeout: TimeoutProvider = .immediate) throws where T: ObservableConvertibleType {
        
        var remainingVerifiers = verifiers
        let nextVerifier = { () throws -> SnapshotVerifier<T.E> in
            guard !remainingVerifiers.isEmpty else {
                throw SnapshotVerifierErrors.notEnoughVerifiers
            }
            return remainingVerifiers.remove(at: 0)
        }
        
        var pendingErrors = [Error]()
        var terminated = false
        
        let shouldWait = { () -> Bool in
            guard pendingErrors.isEmpty && !timeout.hasTimedOut else {
                return false
            }
            guard remainingVerifiers.isEmpty else {
                return true
            }
            return !(terminated || options.contains(.doNotWaitForTermination))
        }
        
        let disposable = observable
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                let snapshot = Snapshot(event: event)
                terminated = (snapshot.event.kind != .next)
                do {
                    try nextVerifier().verify(snapshot)
                } catch {
                    pendingErrors.append(error)
                }
        }
        
        let runloop = RunLoop.current
        while shouldWait() {
            // Note that the runloop wait’s deadline does not necessarily match ours
            // For one, Date does not monotonically increase, but beyond that, this
            // stops us from splitting the responsibility owned by `shouldWait`
            // and can do more flexible timeout calculation
            let loopDeadline = Date(timeIntervalSinceNow: 0.1)
            runloop.run(mode: .defaultRunLoopMode, before: loopDeadline)
        }
        
        disposable.dispose()
        
        let firstUnacceptableError = pendingErrors.first(where: { pendingError in
            guard
                options.contains(.doNotWaitForTermination),
                let e = pendingError as? SnapshotVerifierErrors,
                case .notEnoughVerifiers = e else {
                    return true
            }
            // don’t throw error if we’re matching prefix and error is about count
            return false
        })
        
        if let firstUnacceptableError = firstUnacceptableError {
            throw firstUnacceptableError
        }
        
        guard terminated || options.contains(.doNotWaitForTermination) else {
            throw SnapshotVerifierErrors.didNotTerminate
        }
        
        guard remainingVerifiers.isEmpty else {
            throw SnapshotVerifierErrors.tooManyVerifiers(remainder: remainingVerifiers.count)
        }
    }
    
}
