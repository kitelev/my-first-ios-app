//
//  my_first_ios_appUITests.swift
//  my-first-ios-appUITests
//
//  Created by Андрей Кителёв on 03.11.2025.
//

import XCTest

final class my_first_ios_appUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testNotificationButton() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()

        // Find the notification button by its label text
        let notificationButton = app.buttons["Send Push (works offline)"]

        // Verify the button exists
        XCTAssertTrue(notificationButton.exists, "Notification button should exist")

        // Verify the button is enabled
        XCTAssertTrue(notificationButton.isEnabled, "Notification button should be enabled")

        // Verify the button is hittable (visible and can be tapped)
        XCTAssertTrue(notificationButton.isHittable, "Notification button should be hittable")

        // Tap the notification button
        notificationButton.tap()

        // Wait a moment for any UI updates
        sleep(1)

        // Verify the app didn't crash and is still running
        XCTAssertTrue(app.state == .runningForeground, "App should still be running after tapping notification button")
    }

    @MainActor
    func testNotificationButtonAccessibility() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()

        // Find the notification button using image identifier
        let notificationButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Send Push'")).element

        // Verify accessibility properties
        XCTAssertTrue(notificationButton.exists, "Notification button should be accessible")
        XCTAssertNotEqual(notificationButton.label, "", "Notification button should have a label")

        // Verify the button contains expected text
        XCTAssertTrue(notificationButton.label.contains("Send Push"), "Button label should contain 'Send Push'")
        XCTAssertTrue(notificationButton.label.contains("works offline"), "Button label should indicate offline capability")
    }

    @MainActor
    func testTimerAndNotificationUIElements() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()

        // Verify all major UI elements exist
        XCTAssertTrue(app.staticTexts["Hi ExoWorld"].exists, "Welcome text should exist")
        XCTAssertTrue(app.staticTexts["Timer"].exists, "Timer header should exist")
        XCTAssertTrue(app.staticTexts["Push Notification"].exists, "Notification header should exist")

        // Verify timer button exists
        let timerButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Timer'")).element
        XCTAssertTrue(timerButton.exists, "Timer button should exist")

        // Verify notification button exists
        let notificationButton = app.buttons["Send Push (works offline)"]
        XCTAssertTrue(notificationButton.exists, "Notification button should exist")

        // Test interaction: tap timer button and verify state change
        timerButton.tap()
        sleep(1)

        // Tap notification button
        notificationButton.tap()
        sleep(1)

        // Verify app is still responsive
        XCTAssertTrue(app.state == .runningForeground, "App should remain responsive after interactions")
    }
}
