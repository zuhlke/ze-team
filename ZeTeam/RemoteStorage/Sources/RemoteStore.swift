import Foundation

/// Represents a remote record store.
///
/// This protocol is in development and is not stable.
/// This API is a work in progress: we start from the most basic support for CRUD operations,
/// and we will iteratively improve it to add error handling, asynchrony, batching, etc. as
/// we get closer to a shipable concrete implementation.
protocol RemoteStore {
    
    associatedtype Record: RecordProtocol
    
    func insert(_ record: Record)
    
    func delete(recordWithIdentifier: Record.Identifier)
    
    func update(_ record: Record)
    
    var records: [Record] { get }
    
}
