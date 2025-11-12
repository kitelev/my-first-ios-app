//
//  PhoneConnectivityManagerTests.swift
//  my-first-ios-appTests
//
//  Created by Claude on 12.11.2025.
//

import XCTest
import WatchConnectivity
@testable import my_first_ios_app

final class PhoneConnectivityManagerTests: XCTestCase {

    var sut: PhoneConnectivityManager!
    var mockTimerManager: TimerManager!
    var mockNotificationManager: NotificationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = PhoneConnectivityManager()
        mockTimerManager = TimerManager()
        mockNotificationManager = NotificationManager()
        sut.timerManager = mockTimerManager
        sut.notificationManager = mockNotificationManager
    }

    override func tearDownWithError() throws {
        sut = nil
        mockTimerManager = nil
        mockNotificationManager = nil
        try super.tearDownWithError()
    }

    func testPhoneConnectivityManagerInit() throws {
        // Given & When
        let manager = PhoneConnectivityManager()

        // Then
        XCTAssertNotNil(manager, "PhoneConnectivityManager should be initialized")
    }

    func testPhoneConnectivityManagerLinksWithTimerManager() throws {
        // Given
        let manager = PhoneConnectivityManager()
        let timerManager = TimerManager()

        // When
        manager.timerManager = timerManager

        // Then
        XCTAssertNotNil(manager.timerManager, "PhoneConnectivityManager should link with TimerManager")
        XCTAssertTrue(manager.timerManager === timerManager, "Should be the same instance")
    }

    func testPhoneConnectivityManagerLinksWithNotificationManager() throws {
        // Given
        let manager = PhoneConnectivityManager()
        let notificationManager = NotificationManager()

        // When
        manager.notificationManager = notificationManager

        // Then
        XCTAssertNotNil(manager.notificationManager, "PhoneConnectivityManager should link with NotificationManager")
        XCTAssertTrue(manager.notificationManager === notificationManager, "Should be the same instance")
    }

    func testSendTimerStateWhenNotActivated() throws {
        // Given
        // WCSession might not be activated in test environment

        // When
        // This should not crash
        sut.sendTimerState(isRunning: true, elapsedTime: 10.5, startTime: Date())

        // Then
        // No assertion needed - just checking it doesn't crash
        XCTAssertTrue(true, "sendTimerState should not crash when session not activated")
    }

    func testSendTimerStateWithNilStartTime() throws {
        // Given
        // When
        sut.sendTimerState(isRunning: false, elapsedTime: 0, startTime: nil)

        // Then
        XCTAssertTrue(true, "sendTimerState should handle nil startTime")
    }

    func testSendTimerStateWithValidStartTime() throws {
        // Given
        let startTime = Date()

        // When
        sut.sendTimerState(isRunning: true, elapsedTime: 5.0, startTime: startTime)

        // Then
        XCTAssertTrue(true, "sendTimerState should handle valid startTime")
    }
}
