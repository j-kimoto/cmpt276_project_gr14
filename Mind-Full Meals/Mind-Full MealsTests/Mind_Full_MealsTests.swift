//
//  Mind_Full_MealsTests.swift
//  Mind-Full MealsTests
//
//  Created by Jason Kimoto on 2018-06-28.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import XCTest
@testable import Mind_Full_Meals

class Mind_Full_MealsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    //MARK: Meal Class Tests
    
    // Confirm that the Meal initializer returns a Meal object when passed valid parameters.
    func testMealInitializationSucceeds() {
        let emptyMeal = Meal.init()
        XCTAssertNotNil(emptyMeal)
    }
}
