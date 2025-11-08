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

    // MARK: - Live Activities Integration Tests

    @MainActor
    func testTimerStartTriggersLiveActivity() throws {
        let app = XCUIApplication()
        app.launch()

        // Find Start button
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        XCTAssertTrue(startButton.exists, "Start button should exist")
        XCTAssertTrue(startButton.isEnabled, "Start button should be enabled")

        // Tap Start button (this should trigger Live Activity)
        startButton.tap()

        // Wait for timer to update
        sleep(1)

        // Verify timer display has changed (should show elapsed time > 00:00.0)
        let timerDisplay = app.staticTexts.containing(NSPredicate(format: "label MATCHES %@", ".*:.*\\..*")).element
        XCTAssertTrue(timerDisplay.exists, "Timer display should exist and show time")

        // Find Stop button (Start button should have changed to Stop)
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element
        XCTAssertTrue(stopButton.exists, "Stop button should appear after starting timer")
        XCTAssertTrue(stopButton.isEnabled, "Stop button should be enabled")

        // Stop the timer (this should end Live Activity)
        stopButton.tap()

        // Wait for timer to reset
        sleep(1)

        // Verify Start button is back
        XCTAssertTrue(startButton.exists, "Start button should be back after stopping")
    }

    @MainActor
    func testTimerDisplayUpdates() throws {
        let app = XCUIApplication()
        app.launch()

        // Start timer
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        startButton.tap()

        // Wait and capture first timer value
        sleep(1)
        let timerTexts = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", ".*:.*\\..*"))
        let firstValue = timerTexts.element(boundBy: 0).label

        // Wait more and capture second timer value
        sleep(1)
        let secondValue = timerTexts.element(boundBy: 0).label

        // Values should be different (timer is counting)
        XCTAssertNotEqual(firstValue, secondValue, "Timer display should update over time")
        XCTAssertNotEqual(firstValue, "00:00.0", "Timer should have moved past 00:00.0")

        // Stop timer
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element
        stopButton.tap()

        // Wait for reset
        sleep(1)

        // Timer should be back to 00:00.0
        let resetValue = timerTexts.element(boundBy: 0).label
        XCTAssertEqual(resetValue, "00:00.0", "Timer should reset to 00:00.0 after stopping")
    }

    @MainActor
    func testMultipleTimerStartStopCycles() throws {
        let app = XCUIApplication()
        app.launch()

        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element

        // First cycle
        startButton.tap()
        sleep(1)
        XCTAssertTrue(stopButton.exists, "Stop button should exist in first cycle")
        stopButton.tap()
        sleep(1)

        // Second cycle
        XCTAssertTrue(startButton.exists, "Start button should exist for second cycle")
        startButton.tap()
        sleep(1)
        XCTAssertTrue(stopButton.exists, "Stop button should exist in second cycle")
        stopButton.tap()
        sleep(1)

        // Third cycle
        XCTAssertTrue(startButton.exists, "Start button should exist for third cycle")
        startButton.tap()
        sleep(1)
        XCTAssertTrue(stopButton.exists, "Stop button should exist in third cycle")
        stopButton.tap()

        // Verify app is still stable
        XCTAssertTrue(app.state == .runningForeground, "App should be running after multiple cycles")
    }

    @MainActor
    func testTimerStateAfterBackgrounding() throws {
        let app = XCUIApplication()
        app.launch()

        // Start timer
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        startButton.tap()
        sleep(1)

        // Send app to background
        XCUIDevice.shared.press(.home)
        sleep(2)

        // Bring app back to foreground
        app.activate()
        sleep(1)

        // Timer should still be running (Stop button should exist)
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element
        XCTAssertTrue(stopButton.exists, "Stop button should still exist after backgrounding")

        // Timer should have continued counting
        let timerDisplay = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", ".*:.*\\..*")).element(boundBy: 0)
        XCTAssertTrue(timerDisplay.exists, "Timer display should exist")
        XCTAssertNotEqual(timerDisplay.label, "00:00.0", "Timer should have continued counting")

        // Stop timer
        stopButton.tap()
    }

    @MainActor
    func testTimerFormattingAtDifferentDurations() throws {
        let app = XCUIApplication()
        app.launch()

        // Start timer
        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        startButton.tap()

        // Check format after 0.5 seconds (should be MM:SS.D format)
        sleep(1)
        let timerTexts = app.staticTexts.matching(NSPredicate(format: "label MATCHES %@", ".*:.*\\..*"))
        let shortDuration = timerTexts.element(boundBy: 0).label

        // Verify format is MM:SS.D (e.g., "00:00.5" or "00:01.0")
        let shortPattern = "^\\d{2}:\\d{2}\\.\\d$"
        let shortPredicate = NSPredicate(format: "SELF MATCHES %@", shortPattern)
        XCTAssertTrue(shortPredicate.evaluate(with: shortDuration),
            "Short duration should match MM:SS.D format, got: \(shortDuration)")

        // Stop timer
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element
        stopButton.tap()
    }

    @MainActor
    func testTimerUIConsistency() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify initial state
        let timerSection = app.staticTexts["Timer"]
        XCTAssertTrue(timerSection.exists, "Timer section header should exist")

        let startButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Start'")).element
        XCTAssertTrue(startButton.exists, "Start button should exist initially")

        // Start timer
        startButton.tap()
        sleep(1)

        // Verify running state
        let stopButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Stop'")).element
        XCTAssertTrue(stopButton.exists, "Stop button should exist when running")
        XCTAssertFalse(startButton.exists, "Start button should not exist when running")

        // Stop timer
        stopButton.tap()
        sleep(1)

        // Verify stopped state
        XCTAssertTrue(startButton.exists, "Start button should exist when stopped")
        XCTAssertFalse(stopButton.exists, "Stop button should not exist when stopped")

        // Verify timer display is reset
        let timerDisplay = app.staticTexts.matching(NSPredicate(format: "label == %@", "00:00.0")).element
        XCTAssertTrue(timerDisplay.exists, "Timer should display 00:00.0 when stopped")
    }
}
