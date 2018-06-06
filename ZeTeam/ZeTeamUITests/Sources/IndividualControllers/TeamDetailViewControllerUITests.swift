import XCTest

class TeamDetailViewControllerUITests: XCTestCase {
    
    let application = XCUIApplication()
    let teamName = "team A";
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        application.launch()
        
        removeAllTeams()
        goToTeamDeatailsPage()
    }
    
    private func goToTeamDeatailsPage(){
        let teamElement = addTeam(teamName)
        
        teamElement.tap()
    }
    
    private func removeAllTeams() {
        var cellQuery = application.tables.cells.element(boundBy: 0)
        while cellQuery.exists {
            cellQuery.swipeLeft()
            cellQuery.buttons["Delete"].tap()
            cellQuery = application.tables.cells.element(boundBy: 0)
        }
    }
    
    func testAddAndRemoveTeamMember(){
        let addMemberButton = application.buttons["Add Team Member"]
    
        XCTAssertTrue(addMemberButton.exists)
        
        addMemberButton.tap()
        
        let createButton = application.buttons["Create"];
        
        XCTAssertFalse(createButton.isEnabled)
        
        XCTAssertTrue(application.staticTexts["Add Team Member"].exists)
        
        let cancelButton = application.buttons["Cancel"];
        
        XCTAssertTrue(cancelButton.exists)

        let textField = application.textFields["team member name"]
        textField.typeText("Member name")

        XCTAssertTrue(createButton.isEnabled)

        createButton.tap()
        
        let teamMemberCellQuery = application.tables.cells.element(boundBy: 0)
        
        XCTAssertTrue(teamMemberCellQuery.exists)
        
        XCTAssertTrue(teamMemberCellQuery.staticTexts["Member name"].exists)
        
        teamMemberCellQuery.swipeLeft()
        teamMemberCellQuery.buttons["Delete"].tap()
        
        XCTAssertFalse(teamMemberCellQuery.exists)
        
        runRemoveTeamTests(teamName)
    }

    func testDescriptionEditAndSave(){
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
