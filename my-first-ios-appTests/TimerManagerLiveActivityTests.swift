//
//  TimerManagerLiveActivityTests.swift
//  my-first-ios-appTests
//
//  Created by Claude on 08.11.2025.
//

import XCTest
import ActivityKit
@testable import my_first_ios_app

final class TimerManagerLiveActivityTests: XCTestCase {

    var timerManager: TimerManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        timerManager = TimerManager()
    }

    override func tearDownWithError() throws {
        // Stop timer if running to clean up any Live Activities
        if timerManager.isRunning {
            timerManager.stop()
        }
        timerManager = nil
        try super.tearDownWithError()
    }

    // MARK: - Timer State Tests

    func testTimerManagerInitialState() throws {
        XCTAssertFalse(timerManager.isRunning, "Timer should not be running initially")
        XCTAssertEqual(timerManager.elapsedTime, 0, "Elapsed time should be 0 initially")
    }

    func testTimerStartChangesState() throws {
        timerManager.start()

        XCTAssertTrue(timerManager.isRunning, "Timer should be running after start")

        // Wait for timer to accumulate some time
        let expectation = XCTestExpectation(description: "Timer should accumulate time")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertGreaterThan(self.timerManager.elapsedTime, 0, "Elapsed time should be greater than 0")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testTimerStopResetsState() throws {
        timerManager.start()

        // Wait for some time to elapse
        let startExpectation = XCTestExpectation(description: "Timer should start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertGreaterThan(self.timerManager.elapsedTime, 0, "Timer should have elapsed time")
            self.timerManager.stop()
            startExpectation.fulfill()
        }

        wait(for: [startExpectation], timeout: 1.0)

        XCTAssertFalse(timerManager.isRunning, "Timer should not be running after stop")
        XCTAssertEqual(timerManager.elapsedTime, 0, "Elapsed time should be reset to 0 after stop")
    }

    func testTimerCannotStartTwice() throws {
        timerManager.start()
        let firstStartTime = timerManager.elapsedTime

        // Try to start again
        timerManager.start()

        // Wait a bit
        let expectation = XCTestExpectation(description: "Check timer state")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Timer should still be running from first start
            XCTAssertTrue(self.timerManager.isRunning, "Timer should still be running")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.5)
    }

    // MARK: - Formatted Time Tests

    func testFormattedTimeForZero() throws {
        timerManager.elapsedTime = 0
        let formatted = timerManager.formattedTime()
        XCTAssertEqual(formatted, "00:00.0", "Zero time should be formatted as 00:00.0")
    }

    func testFormattedTimeForSeconds() throws {
        timerManager.elapsedTime = 45.7
        let formatted = timerManager.formattedTime()
        XCTAssertEqual(formatted, "00:45.7", "45.7 seconds should be formatted as 00:45.7")
    }

    func testFormattedTimeForMinutes() throws {
        // 125 seconds = 2 minutes and 5 seconds
        // Setting elapsedTime to exactly 125.0 to avoid floating point precision issues
        timerManager.elapsedTime = 125.0
        let formatted = timerManager.formattedTime()
        XCTAssertEqual(formatted, "02:05.0", "125.0 seconds should be formatted as 02:05.0")
    }

    func testFormattedTimeForHours() throws {
        timerManager.elapsedTime = 3665.8
        let formatted = timerManager.formattedTime()
        XCTAssertEqual(formatted, "01:01:05.8", "3665.8 seconds should be formatted as 01:01:05.8")
    }

    func testFormattedTimeForLargeValues() throws {
        timerManager.elapsedTime = 36000.0
        let formatted = timerManager.formattedTime()
        XCTAssertEqual(formatted, "10:00:00.0", "36000 seconds should be formatted as 10:00:00.0")
    }

    // MARK: - Live Activity Integration Tests

    func testStopTimerFromLiveActivityNotification() throws {
        // Start the timer
        timerManager.start()

        // Wait for timer to start
        let startExpectation = XCTestExpectation(description: "Timer should start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.timerManager.isRunning, "Timer should be running")
            startExpectation.fulfill()
        }

        wait(for: [startExpectation], timeout: 0.5)

        // Post notification to stop timer (simulating Live Activity stop button)
        NotificationCenter.default.post(
            name: NSNotification.Name("StopTimerFromLiveActivity"),
            object: nil
        )

        // Wait for notification to be processed
        let stopExpectation = XCTestExpectation(description: "Timer should stop from notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertFalse(self.timerManager.isRunning, "Timer should be stopped by notification")
            XCTAssertEqual(self.timerManager.elapsedTime, 0, "Elapsed time should be reset")
            stopExpectation.fulfill()
        }

        wait(for: [stopExpectation], timeout: 0.5)
    }

    func testMultipleStartStopCycles() throws {
        // First cycle
        timerManager.start()
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertTrue(timerManager.isRunning, "Timer should be running in first cycle")
        timerManager.stop()
        XCTAssertFalse(timerManager.isRunning, "Timer should be stopped after first cycle")

        // Second cycle
        timerManager.start()
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertTrue(timerManager.isRunning, "Timer should be running in second cycle")
        timerManager.stop()
        XCTAssertFalse(timerManager.isRunning, "Timer should be stopped after second cycle")

        // Third cycle
        timerManager.start()
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertTrue(timerManager.isRunning, "Timer should be running in third cycle")
        timerManager.stop()
        XCTAssertFalse(timerManager.isRunning, "Timer should be stopped after third cycle")
    }

    // MARK: - Timer Accuracy Tests

    func testTimerAccuracy() throws {
        timerManager.start()

        let expectation = XCTestExpectation(description: "Timer accuracy test")

        // Wait for approximately 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let elapsed = self.timerManager.elapsedTime

            // Allow 10% margin of error (0.9 to 1.1 seconds)
            XCTAssertGreaterThanOrEqual(elapsed, 0.9, "Timer should have counted at least 0.9 seconds")
            XCTAssertLessThanOrEqual(elapsed, 1.1, "Timer should not have counted more than 1.1 seconds")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.5)
    }

    func testTimerUpdateFrequency() throws {
        timerManager.start()

        var previousTime: TimeInterval = 0
        var updateCount = 0
        let expectedUpdates = 5 // Expect at least 5 updates in 0.6 seconds (timer updates every 0.1s)

        let expectation = XCTestExpectation(description: "Timer update frequency test")

        // Check updates over 0.6 seconds
        var checks = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            checks += 1
            let currentTime = self.timerManager.elapsedTime

            if currentTime > previousTime {
                updateCount += 1
                previousTime = currentTime
            }

            if checks >= 6 {
                timer.invalidate()
                XCTAssertGreaterThanOrEqual(updateCount, expectedUpdates,
                    "Timer should update at least \(expectedUpdates) times in 0.6 seconds")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
