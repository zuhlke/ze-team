import XCTest
import UIKit
import RxSwift
@testable import ZeTeam

class TeamsListViewControllerUITests: ZeTeamUITests {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testTitleExists(){
        XCTAssertTrue(application.navigationBars["Teams"].exists)
    }
    
    func testAddTeamButtonExists(){
        XCTAssertTrue(application.navigationBars.buttons["add"].exists)
    }
    
    func testShowAddNewTeamPopupOnAddClick(){
        tapAddButton()
        
        XCTAssertTrue(application.staticTexts["Create a New Team"].exists)
    }
    
    func testCanCancelAddingNewTeam(){
        tapAddButton()
        
        let cancelButton = application.buttons["Cancel"];
    
        XCTAssertTrue(cancelButton.exists)
        
        cancelButton.tap()
        
        XCTAssertFalse(application.staticTexts["Create a New Team"].exists)
    }
    
    func testAddAndRemoveTeam(){
        let teamName = "team A";
        runAddTeamTests(teamName);
        runRemoveTeamTests(teamName);
    }
    
    private func runAddTeamTests(_ teamName : String){
        tapAddButton()
        
        let createButton = application.buttons["Create"];
        
        XCTAssertFalse(createButton.isEnabled)
        
        let textField = application.textFields["team name"]
        textField.typeText(teamName)
        XCTAssertTrue(createButton.isEnabled)
        
        createButton.tap()
        XCTAssertFalse(application.staticTexts["Create a New Team"].exists)
    }
    
    private func runRemoveTeamTests(_ teamName : String){
        let cellQuery = application.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cellQuery.exists)
        XCTAssertTrue(cellQuery.staticTexts[teamName].exists)
        
        cellQuery.swipeLeft()
        cellQuery.buttons["Delete"].tap()
        
        XCTAssertFalse(cellQuery.exists)
    }
    
}
