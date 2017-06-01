//
//  KaupunkifillaritUITests.swift
//  KaupunkifillaritUITests
//
//  Created by Lauri Piispanen on 30/05/2017.
//  Copyright © 2017 Lauri Piispanen. All rights reserved.
//

import XCTest

class KaupunkifillaritUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreenShot() {
        let app = XCUIApplication()
        let map = app.maps.element

        Thread.sleep(forTimeInterval: 5)

        snapshot("01Launch")

        map.pinch(withScale: 3, velocity: 1)
        map.swipeLeft()

        snapshot("02Zoomed")
    }
    
}
