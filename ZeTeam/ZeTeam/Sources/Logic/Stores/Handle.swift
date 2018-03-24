import Foundation

final class Handle<Content: Codable>: Codable {
    
    let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
}
