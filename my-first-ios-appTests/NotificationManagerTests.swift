//
//  NotificationManagerTests.swift
//  my-first-ios-appTests
//
//  Created by Claude on 09.11.2025.
//

import XCTest
import UserNotifications
@testable import my_first_ios_app

final class NotificationManagerTests: XCTestCase {

    var notificationManager: NotificationManager!
    var mockCenter: MockUserNotificationCenter!

    override func setUpWithError() throws {
        notificationManager = NotificationManager()
        mockCenter = MockUserNotificationCenter()
    }

    override func tearDownWithError() throws {
        notificationManager = nil
        mockCenter = nil
    }

    // MARK: - Test Notification Category Setup

    func testNotificationCategoryIsConfigured() throws {
        // Given: NotificationManager is initialized
        // When: Categories are set up
        notificationManager.requestAuthorization()

        // Wait for async setup
        let expectation = XCTestExpectation(description: "Categories configured")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then: Verify TIMER_CATEGORY exists
            UNUserNotificationCenter.current().getNotificationCategories { categories in
                let timerCategory = categories.first { $0.identifier == "TIMER_CATEGORY" }
                XCTAssertNotNil(timerCategory, "TIMER_CATEGORY should be configured")

                // Verify Stop action exists
                if let category = timerCategory {
                    let stopAction = category.actions.first { $0.identifier == "STOP_TIMER_ACTION" }
                    XCTAssertNotNil(stopAction, "STOP_TIMER_ACTION should exist")
                    XCTAssertEqual(stopAction?.title, "⏹️ Stop", "Stop action should have correct title")
                }

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test Stop Action Options

    func testStopActionHasCorrectOptions() throws {
        // Given: NotificationManager is initialized
        notificationManager.requestAuthorization()

        // Wait for async setup
        let expectation = XCTestExpectation(description: "Action options verified")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UNUserNotificationCenter.current().getNotificationCategories { categories in
                let timerCategory = categories.first { $0.identifier == "TIMER_CATEGORY" }

                if let category = timerCategory {
                    let stopAction = category.actions.first { $0.identifier == "STOP_TIMER_ACTION" }

                    // Then: Action should have destructive and foreground options
                    if let action = stopAction {
                        XCTAssertTrue(action.options.contains(.destructive), "Stop action should be destructive")
                        XCTAssertTrue(action.options.contains(.foreground), "Stop action should bring app to foreground")
                    }
                }

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test Category Options

    func testTimerCategoryHasCorrectOptions() throws {
        // Given: NotificationManager is initialized
        notificationManager.requestAuthorization()

        let expectation = XCTestExpectation(description: "Category options verified")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UNUserNotificationCenter.current().getNotificationCategories { categories in
                let timerCategory = categories.first { $0.identifier == "TIMER_CATEGORY" }

                // Then: Category should have correct options
                if let category = timerCategory {
                    XCTAssertTrue(category.options.contains(.customDismissAction), "Should have custom dismiss action")
                    XCTAssertTrue(category.options.contains(.allowInCarPlay), "Should allow in CarPlay")
                }

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Mock User Notification Center

class MockUserNotificationCenter {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []

    func add(_ request: UNNotificationRequest) {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
}
