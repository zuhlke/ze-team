import XCTest

class TeamDetailViewControllerUITests: XCTestCase {
    
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
    
    func testDescriptionEditAndSave(){
        let teamName = "team A";
        let teamElement = addTeam(teamName)
        
        teamElement.tap()
        
        let editButton = application.navigationBars.buttons["Edit"]
        
        XCTAssertTrue(editButton.exists)
        XCTAssertTrue(application.staticTexts["teamDescription"].exists)
        
        editButton.tap()
        
        let saveButton = application.navigationBars.buttons["Save"]
        
        XCTAssertTrue(application.textViews["teamDescriptionEdit"].exists)
        XCTAssertTrue(saveButton.exists)
        
        saveButton.tap()
        
        XCTAssertTrue(editButton.exists)
        XCTAssertTrue(application.staticTexts["teamDescription"].exists)
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
}
