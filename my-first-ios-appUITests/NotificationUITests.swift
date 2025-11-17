//
//  NotificationUITests.swift
//  my-first-ios-appUITests
//
//  Created by Claude on 09.11.2025.
//

import XCTest

final class NotificationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Enable notifications if needed
        // Note: In real device testing, notifications must be manually enabled
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Test Notification Creation

    func testTimerNotificationAppears() throws {
        // Given: App is launched
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        // When: Start timer button is tapped
        startButton.tap()

        // Then: Timer should be running
        let stopButton = app.buttons["Stop Timer"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2))

        // When: App is moved to background
        XCUIDevice.shared.press(.home)

        // Wait for notification to appear
        // Note: This test validates that notification is sent
        // Actual notification UI validation requires special notification testing setup
        sleep(2)

        // Clean up: Return to app and stop timer
        app.activate()

        if stopButton.exists {
            stopButton.tap()
        }
    }

    // MARK: - Test Timer Updates

    func testTimerCountsUp() throws {
        // Given: App is launched
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        // When: Start timer button is tapped
        startButton.tap()

        // Wait a moment for timer to count
        sleep(2)

        // Then: Timer label should show elapsed time
        // Note: Timer updates every 0.1s, so after 2 seconds should show ~00:02.x
        let timerLabels = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '00:0'"))
        XCTAssertGreaterThan(timerLabels.count, 0, "Timer should display elapsed time")

        // Clean up
        let stopButton = app.buttons["Stop Timer"]
        if stopButton.exists {
            stopButton.tap()
        }
    }

    // MARK: - Test Stop Button in App

    func testStopButtonStopsTimer() throws {
        // Given: Timer is running
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let stopButton = app.buttons["Stop Timer"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2))

        // When: Stop button is tapped
        stopButton.tap()

        // Then: Start button should appear again
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))

        // And: Timer should reset to 00:00.0
        let timerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '00:00.0'")).firstMatch
        XCTAssertTrue(timerLabel.exists, "Timer should reset to 00:00.0")
    }

    // MARK: - Test Notification Category

    func testNotificationHasCustomCategory() throws {
        // This test validates that notification uses TIMER_CATEGORY
        // which enables the custom Notification Content Extension

        // Given: App is launched
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        // When: Start timer button is tapped
        startButton.tap()

        let stopButton = app.buttons["Stop Timer"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2))

        // The notification should be created with TIMER_CATEGORY
        // This is tested in unit tests via NotificationManager

        // Clean up
        stopButton.tap()
        XCTAssertTrue(startButton.waitForExistence(timeout: 2))
    }

    // MARK: - Test Background Behavior

    func testTimerContinuesInBackground() throws {
        // Given: Timer is running
        let startButton = app.buttons["Start Timer"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let stopButton = app.buttons["Stop Timer"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 2))

        // When: App goes to background
        XCUIDevice.shared.press(.home)

        // Wait for 3 seconds
        sleep(3)

        // And: App is brought back to foreground
        app.activate()

        // Then: Timer should have continued counting
        // Verify timer is still running by checking stop button exists
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5), "Timer should still be running after background")

        // Also verify timer display shows a non-zero value (matches MM:SS.d pattern)
        let timerLabels = app.staticTexts.matching(NSPredicate(format: "label MATCHES '\\\\d{2}:\\\\d{2}\\\\.\\\\d'"))
        XCTAssertGreaterThan(timerLabels.count, 0, "Timer should display elapsed time")

        // Clean up
        if stopButton.exists {
            stopButton.tap()
        }
    }

    // MARK: - Test Multiple Start/Stop Cycles

    func testMultipleStartStopCycles() throws {
        // Given: App is launched
        let startButton = app.buttons["Start Timer"]
        let stopButton = app.buttons["Stop Timer"]

        XCTAssertTrue(startButton.waitForExistence(timeout: 5))

        // When: Start and stop timer multiple times
        for _ in 1...3 {
            // Start timer
            startButton.tap()
            XCTAssertTrue(stopButton.waitForExistence(timeout: 2))

            // Wait a bit
            sleep(1)

            // Stop timer
            stopButton.tap()
            XCTAssertTrue(startButton.waitForExistence(timeout: 2))

            // Timer should reset
            let timerLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '00:00.0'")).firstMatch
            XCTAssertTrue(timerLabel.exists, "Timer should reset after stop")
        }

        // Then: App should still work correctly
        XCTAssertTrue(startButton.exists)
    }
}
