//
//  TimerManager.swift
//  my-first-ios-app
//
//  Created by Claude on 03.11.2025.
//

import Foundation
import Combine
import ActivityKit
import UserNotifications

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0

    private var startTime: Date?
    private var timer: Timer?
    private var liveActivity: Activity<TimerActivityAttributes>?
    private let timerNotificationID = "TIMER_NOTIFICATION"

    init() {
        // Listen for stop timer notifications from Live Activity
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStopFromLiveActivity),
            name: NSNotification.Name("StopTimerFromLiveActivity"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleStopFromLiveActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.stop()
        }
    }

    func start() {
        guard !isRunning else { return }

        let now = Date()
        startTime = now
        isRunning = true
        elapsedTime = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)

            // Update Live Activity
            self.updateLiveActivity()

            // Update notification every second
            if Int(self.elapsedTime * 10) % 10 == 0 {
                self.updateTimerNotification()
            }
        }

        // Start Live Activity
        startLiveActivity(startTime: now)

        // Send initial timer notification
        updateTimerNotification()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        startTime = nil
        elapsedTime = 0

        // End Live Activity
        endLiveActivity()

        // Remove timer notification
        removeTimerNotification()
    }

    func formattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        let milliseconds = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 10)

        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
        }
    }

    // MARK: - Live Activity Methods

    private func startLiveActivity(startTime: Date) {
        // Detailed diagnostics for Live Activities
        let authInfo = ActivityAuthorizationInfo()
        print("🔍 Live Activity Diagnostics:")
        print("  - areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")
        print("  - frequentPushesEnabled: \(authInfo.frequentPushesEnabled)")

        #if targetEnvironment(simulator)
        print("  - Running on: SIMULATOR")
        #else
        print("  - Running on: REAL DEVICE")
        #endif

        if #available(iOS 16.1, *) {
            print("  - iOS version: 16.1+ ✅")
        } else {
            print("  - iOS version: < 16.1 ❌")
            return
        }

        // Check if Live Activities are supported
        guard authInfo.areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled in system settings")
            print("   Please enable in Settings → [Your App] → Live Activities")
            return
        }

        let attributes = TimerActivityAttributes(startTime: startTime)
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: true
        )

        print("🚀 Attempting to start Live Activity...")

        do {
            liveActivity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("✅ Live Activity started successfully!")
            print("   ID: \(liveActivity?.id ?? "unknown")")
            if let activity = liveActivity {
                print("   State: \(activity.activityState)")
            }
        } catch {
            print("❌ Error starting Live Activity:")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            print("   Error type: \(type(of: error))")
        }
    }

    private func updateLiveActivity() {
        guard let activity = liveActivity else { return }

        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: elapsedTime,
            isRunning: isRunning
        )

        Task {
            await activity.update(
                .init(state: contentState, staleDate: nil)
            )
        }
    }

    private func endLiveActivity() {
        guard let activity = liveActivity else { return }

        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: elapsedTime,
            isRunning: false
        )

        Task {
            await activity.end(
                .init(state: contentState, staleDate: nil),
                dismissalPolicy: .immediate
            )
            print("✅ Live Activity ended")
        }

        liveActivity = nil
    }

    // MARK: - Timer Notification Methods

    private func updateTimerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "⏱️ Timer Running"
        content.body = formattedTime()
        content.sound = nil // Без звука при обновлении
        content.categoryIdentifier = "TIMER_CATEGORY" // Используем категорию с кнопкой Stop
        content.threadIdentifier = timerNotificationID

        // Используем trigger nil для немедленной доставки
        let request = UNNotificationRequest(
            identifier: timerNotificationID,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error updating timer notification: \(error.localizedDescription)")
            } else {
                print("✅ Timer notification sent: \(self.formattedTime())")
            }
        }
    }

    private func removeTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timerNotificationID])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [timerNotificationID])
        print("✅ Timer notification removed")
    }
}
