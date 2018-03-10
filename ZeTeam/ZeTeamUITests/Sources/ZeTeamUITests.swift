import XCTest

class ZeTeamUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testThatTheAppShowsTheWelcomeMessage() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.navigationBars["Teams"].exists)
    }
    
}
