//
//  TimerActivityAttributesTests.swift
//  my-first-ios-appTests
//
//  Created by Claude on 08.11.2025.
//

import XCTest
import ActivityKit
@testable import my_first_ios_app

final class TimerActivityAttributesTests: XCTestCase {

    // MARK: - TimerActivityAttributes Tests

    func testTimerActivityAttributesCreation() throws {
        let startTime = Date()
        let attributes = TimerActivityAttributes(startTime: startTime)

        XCTAssertEqual(attributes.startTime, startTime, "Start time should match the provided value")
    }

    func testTimerActivityAttributesWithDifferentDates() throws {
        let pastDate = Date(timeIntervalSinceNow: -3600) // 1 hour ago
        let futureDate = Date(timeIntervalSinceNow: 3600) // 1 hour from now
        let currentDate = Date()

        let pastAttributes = TimerActivityAttributes(startTime: pastDate)
        let futureAttributes = TimerActivityAttributes(startTime: futureDate)
        let currentAttributes = TimerActivityAttributes(startTime: currentDate)

        XCTAssertEqual(pastAttributes.startTime, pastDate)
        XCTAssertEqual(futureAttributes.startTime, futureDate)
        XCTAssertEqual(currentAttributes.startTime, currentDate)
    }

    // MARK: - ContentState Tests

    func testContentStateCreation() throws {
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: 42.5,
            isRunning: true
        )

        XCTAssertEqual(contentState.elapsedTime, 42.5, "Elapsed time should be 42.5")
        XCTAssertTrue(contentState.isRunning, "isRunning should be true")
    }

    func testContentStateWithZeroElapsedTime() throws {
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: false
        )

        XCTAssertEqual(contentState.elapsedTime, 0, "Elapsed time should be 0")
        XCTAssertFalse(contentState.isRunning, "isRunning should be false")
    }

    func testContentStateWithLargeElapsedTime() throws {
        let largeTime: TimeInterval = 3600 * 24 // 24 hours
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: largeTime,
            isRunning: true
        )

        XCTAssertEqual(contentState.elapsedTime, largeTime, "Elapsed time should be 24 hours")
        XCTAssertTrue(contentState.isRunning, "isRunning should be true")
    }

    // MARK: - Codable Tests

    func testContentStateCodable() throws {
        let originalState = TimerActivityAttributes.ContentState(
            elapsedTime: 123.456,
            isRunning: true
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalState)

        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(TimerActivityAttributes.ContentState.self, from: data)

        XCTAssertEqual(decodedState.elapsedTime, originalState.elapsedTime,
            "Decoded elapsed time should match original")
        XCTAssertEqual(decodedState.isRunning, originalState.isRunning,
            "Decoded isRunning should match original")
    }

    func testContentStateCodableWithZeroValues() throws {
        let originalState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: false
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalState)

        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(TimerActivityAttributes.ContentState.self, from: data)

        XCTAssertEqual(decodedState.elapsedTime, 0, "Decoded elapsed time should be 0")
        XCTAssertFalse(decodedState.isRunning, "Decoded isRunning should be false")
    }

    // MARK: - Hashable Tests

    func testContentStateHashable() throws {
        let state1 = TimerActivityAttributes.ContentState(elapsedTime: 10.5, isRunning: true)
        let state2 = TimerActivityAttributes.ContentState(elapsedTime: 10.5, isRunning: true)
        let state3 = TimerActivityAttributes.ContentState(elapsedTime: 20.0, isRunning: false)

        XCTAssertEqual(state1, state2, "States with same values should be equal")
        XCTAssertNotEqual(state1, state3, "States with different values should not be equal")

        // Test in a Set
        let stateSet: Set<TimerActivityAttributes.ContentState> = [state1, state2, state3]
        XCTAssertEqual(stateSet.count, 2, "Set should contain 2 unique states (state1 and state2 are equal)")
    }

    func testContentStateHashableInDictionary() throws {
        let state1 = TimerActivityAttributes.ContentState(elapsedTime: 5.0, isRunning: true)
        let state2 = TimerActivityAttributes.ContentState(elapsedTime: 5.0, isRunning: true)
        let state3 = TimerActivityAttributes.ContentState(elapsedTime: 10.0, isRunning: false)

        var dictionary: [TimerActivityAttributes.ContentState: String] = [:]
        dictionary[state1] = "First"
        dictionary[state2] = "Second" // Should overwrite "First" since state1 == state2
        dictionary[state3] = "Third"

        XCTAssertEqual(dictionary.count, 2, "Dictionary should have 2 entries")
        XCTAssertEqual(dictionary[state1], "Second", "state1 key should return 'Second' value")
        XCTAssertEqual(dictionary[state3], "Third", "state3 key should return 'Third' value")
    }

    // MARK: - Realistic Scenario Tests

    func testRealisticTimerScenario() throws {
        // Simulate starting a timer
        let startTime = Date()
        let attributes = TimerActivityAttributes(startTime: startTime)

        // Initial state: timer just started
        let initialState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: true
        )

        XCTAssertEqual(initialState.elapsedTime, 0)
        XCTAssertTrue(initialState.isRunning)

        // Mid-run state: timer has been running for 30 seconds
        let runningState = TimerActivityAttributes.ContentState(
            elapsedTime: 30.0,
            isRunning: true
        )

        XCTAssertEqual(runningState.elapsedTime, 30.0)
        XCTAssertTrue(runningState.isRunning)

        // Final state: timer stopped at 45 seconds
        let stoppedState = TimerActivityAttributes.ContentState(
            elapsedTime: 45.0,
            isRunning: false
        )

        XCTAssertEqual(stoppedState.elapsedTime, 45.0)
        XCTAssertFalse(stoppedState.isRunning)
    }

    func testContentStateTransitions() throws {
        // Test a sequence of state transitions
        var states: [TimerActivityAttributes.ContentState] = []

        // Start
        states.append(TimerActivityAttributes.ContentState(elapsedTime: 0, isRunning: true))

        // Running at various intervals
        for i in 1...5 {
            states.append(TimerActivityAttributes.ContentState(
                elapsedTime: Double(i * 10),
                isRunning: true
            ))
        }

        // Stop
        states.append(TimerActivityAttributes.ContentState(elapsedTime: 50, isRunning: false))

        // Verify all states are valid and properly sequenced
        XCTAssertEqual(states.count, 7, "Should have 7 states (1 start + 5 running + 1 stop)")

        for i in 0..<states.count - 1 {
            if i < states.count - 2 {
                XCTAssertTrue(states[i].isRunning, "State \(i) should be running")
            }
            XCTAssertLessThanOrEqual(states[i].elapsedTime, states[i + 1].elapsedTime,
                "Elapsed time should be monotonically increasing")
        }

        XCTAssertFalse(states.last!.isRunning, "Final state should not be running")
    }

    // MARK: - Edge Case Tests

    func testContentStateWithNegativeElapsedTime() throws {
        // While not realistic, test that the type can handle it
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: -1.0,
            isRunning: false
        )

        XCTAssertEqual(contentState.elapsedTime, -1.0, "Should accept negative elapsed time")
    }

    func testContentStateWithVerySmallElapsedTime() throws {
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: 0.001,
            isRunning: true
        )

        XCTAssertEqual(contentState.elapsedTime, 0.001, "Should handle very small elapsed times")
    }

    func testContentStateWithMaxElapsedTime() throws {
        let maxTime = TimeInterval.greatestFiniteMagnitude / 2 // Use a large but safe value
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: maxTime,
            isRunning: true
        )

        XCTAssertEqual(contentState.elapsedTime, maxTime, "Should handle very large elapsed times")
    }
}
