import XCTest
@testable import ZeTeam

class SequentialIdentifierTests: XCTestCase {
    
    func testThatIdentifierIsNotEqualToItsNext() {
        let initial = SequentialIdentifier.initial
        XCTAssertNotEqual(initial, initial.next())
    }
    
    func testEqualityIsConservedAfterCoding() throws {
        
        let identifier = SequentialIdentifier.initial.next()
        
        let reloaded: SequentialIdentifier = try {
            // identifier is a single value, so we may not be able to write it out as JSON
            // wrap it in an ad-hoc type
            struct Box: Codable {
                var identifier: SequentialIdentifier
            }
            
            let encoded = try JSONEncoder().encode(Box(identifier: identifier))
            return try JSONDecoder().decode(Box.self, from: encoded).identifier
        }()
        
        XCTAssertEqual(identifier, reloaded)
    }
    
    func testUniquenessChainGuaranteeIsNotObviouslyBroken()  {
        
        let identifiers = SequentialIdentifier.initial.nextIdentifiers()
        
        let n = 1000
        
        XCTAssertEqual(Set(identifiers.prefix(n)).count, n)
    }
    
}
