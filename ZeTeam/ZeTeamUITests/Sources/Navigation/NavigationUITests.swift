import XCTest

class NavigationUITests: XCTestCase {
    
    let application = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMoveToTeamDetailsWhenTappingTeanInList(){
        let teamName = "team A";
        let teamElement = addTeam(teamName)
        
        teamElement.tap()
        
        XCTAssertTrue(application.navigationBars[teamName].exists)
        
        let backButton = application.navigationBars.buttons["Teams"]
        
        XCTAssertTrue(backButton.exists)
        
        backButton.tap()
        
        XCTAssertFalse(application.navigationBars[teamName].exists)
        
        clearTeam(teamElement)
    }

    private func addTeam(_ teamName : String) -> XCUIElement {
        tapAddButton()
        
        let createButton = application.buttons["Create"];
        let textField = application.textFields["team name"]
        textField.typeText(teamName)
        
        createButton.tap()
        
        return application.tables.cells.element(boundBy: 0)
    }
    
    private func tapAddButton(){
        let addButton = application.navigationBars.buttons["add"]
        addButton.tap()
    }
    
    private func clearTeam(_ cell : XCUIElement){
        cell.swipeLeft()
        cell.buttons["Delete"].tap()
    }
    
}
