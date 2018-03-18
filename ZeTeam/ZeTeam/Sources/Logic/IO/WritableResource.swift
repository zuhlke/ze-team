import Foundation
import RxSwift

protocol WritableResource {
    
    /// Must return exactly one value before terminating.
    var data: Observable<Data?> { get }
    
    func write(_ data: Data)
    
}
