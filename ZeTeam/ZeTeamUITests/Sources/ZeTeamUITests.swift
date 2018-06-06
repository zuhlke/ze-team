import XCTest

class ZeTeamUITests: XCTestCase {
    
    let application = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        application.launch()
        removeAllTeams()
    }
    
    private func removeAllTeams() {
        var cellQuery = application.tables.cells.element(boundBy: 0)
        while cellQuery.exists {
            cellQuery.swipeLeft()
            cellQuery.buttons["Delete"].tap()
            cellQuery = application.tables.cells.element(boundBy: 0)
        }
    }
    
    internal func tapAddButton(){
        let addButton = application.navigationBars.buttons["add"]
        addButton.tap()
    }
}
