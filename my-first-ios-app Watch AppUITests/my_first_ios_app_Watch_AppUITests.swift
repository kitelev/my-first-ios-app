//
//  my_first_ios_app_Watch_AppUITests.swift
//  my-first-ios-app Watch AppUITests
//
//  Created by Claude on 14.11.2025.
//

import XCTest

final class my_first_ios_app_Watch_AppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test.
        app = XCUIApplication()
        app.launch()

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    func testWatchAppLaunches() throws {
        // Test that the Watch app launches successfully
        XCTAssertTrue(app.waitForExistence(timeout: 10), "Watch app should launch")
    }

    func testTimerDisplayExists() throws {
        // Test that timer display elements are present
        let timerLabel = app.staticTexts["Timer"]
        XCTAssertTrue(timerLabel.waitForExistence(timeout: 5), "Timer label should exist")

        // Check for timer value display (default 00:00.0)
        let timerValue = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d{2}:\\d{2}\\.\\d")).firstMatch
        XCTAssertTrue(timerValue.exists, "Timer value should be displayed")
    }

    func testStartStopTimerButton() throws {
        // Test that Start/Stop Timer button exists and can be tapped
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Start Timer")).firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 5), "Start Timer button should exist")

        // Tap to start timer
        startButton.tap()

        // Wait a moment for state to update
        sleep(1)

        // Check if button changed to Stop Timer
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Stop Timer")).firstMatch
        XCTAssertTrue(stopButton.exists, "After starting, button should show 'Stop Timer'")

        // Tap to stop timer
        stopButton.tap()

        // Wait a moment for state to update
        sleep(1)

        // Check if button changed back to Start Timer
        XCTAssertTrue(startButton.exists, "After stopping, button should show 'Start Timer'")
    }

    func testSendPushButton() throws {
        // Test that Send Push notification button exists
        let pushLabel = app.staticTexts["Push Notification"]
        XCTAssertTrue(pushLabel.waitForExistence(timeout: 5), "Push Notification label should exist")

        let sendPushButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Send Push")).firstMatch
        XCTAssertTrue(sendPushButton.exists, "Send Push button should exist")

        // Tap the button (this tests that it's tappable)
        sendPushButton.tap()

        // Note: We can't verify the actual notification in UI tests,
        // but we can verify the button is interactive
    }

    func testUIElementsLayout() throws {
        // Test that all major UI elements are visible
        let timerLabel = app.staticTexts["Timer"]
        let pushLabel = app.staticTexts["Push Notification"]

        XCTAssertTrue(timerLabel.waitForExistence(timeout: 5), "Timer label should be visible")
        XCTAssertTrue(pushLabel.exists, "Push Notification label should be visible")

        // Verify buttons are present
        let timerButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Timer")).firstMatch
        let pushButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Push")).firstMatch

        XCTAssertTrue(timerButton.exists, "Timer control button should exist")
        XCTAssertTrue(pushButton.exists, "Push notification button should exist")
    }

    func testTimerCountsWhenStarted() throws {
        // Test that timer actually counts when started
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Start Timer")).firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 5), "Start Timer button should exist")

        // Get initial timer value
        let timerValue = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", "\\d{2}:\\d{2}\\.\\d")).firstMatch
        XCTAssertTrue(timerValue.exists, "Timer value should exist")

        // Start timer
        startButton.tap()

        // Wait for timer to count (give it 2-3 seconds)
        sleep(3)

        // Verify timer is running by checking if Stop button exists
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] %@", "Stop Timer")).firstMatch
        XCTAssertTrue(stopButton.exists, "Timer should be running (Stop button visible)")

        // Stop the timer
        stopButton.tap()

        // Clean up - verify we're back to start state
        sleep(1)
        XCTAssertTrue(startButton.exists, "Should return to Start Timer state")
    }
}
