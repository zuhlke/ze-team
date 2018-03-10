import XCTest
import RxSwift

struct TimeoutProvider {
    private var check: () -> Bool
    
    init(check: @escaping () -> Bool) {
        self.check = check
    }
    
    var hasTimedOut: Bool {
        return check()
    }
}

extension TimeoutProvider {
    
    static let immediate = TimeoutProvider { true }
    
    /// A value that never times out
    ///
    /// Using this value is discouraged. It is only defined to help when developing
    /// the tests and until a good replacement for it is created.
    @available(*, deprecated, message: "Never timing out can cause tests to deadlock. Consider finding a better solution.")
    static let never = TimeoutProvider { false }

    /// A value that times out after a fixed duration
    ///
    /// Using this value is discouraged. It is only defined to help when developing
    /// the tests and until a good replacement for it is created.
    @available(*, deprecated, message: "Timing out after a fixed duration is unpredictable. Consider finding a better solution.")
    static func after(_ timeInvertal: TimeInterval) -> TimeoutProvider {
        let deadline = CACurrentMediaTime() + timeInvertal
        return TimeoutProvider { deadline < CACurrentMediaTime() }
    }
    
    static func byChecking(_ variable: Variable<Bool>) -> TimeoutProvider {
        return TimeoutProvider { return variable.value }
    }
    
}
