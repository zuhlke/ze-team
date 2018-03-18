import Foundation
import RxSwift

protocol WritableResource {
    
    var data: Observable<Data?> { get }
    
    func write(_ data: Data)
    
}
