import Foundation
import RxSwift

protocol WritableResource {
    
    func read() -> Observable<Data?>
    
    func write(_ data: Data) -> Observable<Void>
    
}
