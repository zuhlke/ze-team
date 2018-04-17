import Foundation

final class Handle<Content> {
    
    let content: Content
    private let _delete: Action
    
    init(content: Content, delete: @escaping Action) {
        self.content = content
        _delete = delete
    }
    
    func delete() {
        _delete()
    }
    
}
