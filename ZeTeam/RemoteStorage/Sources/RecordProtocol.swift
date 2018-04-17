import Foundation

protocol RecordProtocol {
    associatedtype Identifier
    
    var identifier: Identifier { get }
}
