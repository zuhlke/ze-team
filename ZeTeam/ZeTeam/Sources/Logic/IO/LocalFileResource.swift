import Foundation
import RxSwift

struct LocalFileResource: WritableResource {
    private var url: URL
    private var queue: DispatchQueue
    
    init(url: URL, queue: DispatchQueue) {
        precondition(url.isFileURL)
        self.url = url
        self.queue = queue
    }
    
    var data: Observable<Data?> {
        return Observable.just(url)
            .map { try? Data(contentsOf: $0) }
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: queue))
    }
    
    func write(_ data: Data) {
        queue.async {
            try? data.write(to: self.url)
        }
    }
    
}
