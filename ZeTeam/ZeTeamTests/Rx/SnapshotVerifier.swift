import Foundation
import RxSwift

struct SnapshotVerifier<Element> {
    private var base: (Snapshot<Element>) throws -> Void
    
    init(_ base: @escaping (Snapshot<Element>) throws -> Void) {
        self.base = base
    }
    
    func verify(_ snapshot: Snapshot<Element>) throws {
        try base(snapshot)
    }
    
}

extension SnapshotVerifier {
    
    static func any() -> SnapshotVerifier<Element> {
        return SnapshotVerifier<Element> { _ in }
    }
    
    static func event(verify: @escaping (Event<Element>) throws -> Void) -> SnapshotVerifier<Element> {
        return SnapshotVerifier<Element> { snapshot in
            try verify(snapshot.event)
        }
    }
    
    static func next(verify: @escaping (Element) throws -> Void) -> SnapshotVerifier<Element> {
        return .event { event in
            switch event {
            case .next(let element):
                try verify(element)
            default:
                throw SnapshotVerifierErrors
                    .eventKindMismatch(expected: .next, actual: event.kind)
            }
        }
    }
    
    static func completed(verify: @escaping () throws -> Void = { }) -> SnapshotVerifier<Element> {
        return .event { event in
            switch event {
            case .completed:
                try verify()
            default:
                throw SnapshotVerifierErrors
                    .eventKindMismatch(expected: .completed, actual: event.kind)
            }
        }
    }
    
    static func error(verify: @escaping (Error) throws -> Void = { _ in }) -> SnapshotVerifier<Element> {
        return .event { event in
            switch event {
            case .error(let error):
                try verify(error)
            default:
                throw SnapshotVerifierErrors
                    .eventKindMismatch(expected: .error, actual: event.kind)
            }
        }
    }
    
}

extension SnapshotVerifier where Element: Equatable {
    
    static func next(_ expected: Element) -> SnapshotVerifier<Element> {
        return .next { value in
            guard expected == value else {
                throw SnapshotVerifierErrors.unexpectedValue(expected: expected, actual: value)
            }
        }
    }
        
}
