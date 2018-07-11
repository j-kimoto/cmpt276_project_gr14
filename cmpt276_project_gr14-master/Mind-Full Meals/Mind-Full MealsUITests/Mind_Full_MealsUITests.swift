//
//  Mind_Full_MealsUITests.swift
//  Mind-Full MealsUITests
//
//  Created by Jason Kimoto on 2018-06-28.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import XCTest

class Mind_Full_MealsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        let viewMealsButton = app.buttons["View Meals"]
        viewMealsButton.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["1"]/*[[".cells.staticTexts[\"1\"]",".staticTexts[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Setting"].tap()
        app.buttons["Log Out"].tap()
        viewMealsButton.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 16).otherElements.containing(.staticText, identifier:"  ").element.tap()
        
        let collectionView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .collectionView).element
        collectionView.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 19).otherElements.containing(.staticText, identifier:"  ").element.tap()
        collectionView.tap()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
