//
//  NotificationManager.swift
//  my-first-ios-app
//
//  Created by Claude on 04.11.2025.
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    @Published var isAuthorized = false

    init() {
        checkAuthorizationStatus()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func sendNotification(title: String, body: String, delay: TimeInterval = 1) {
        guard isAuthorized else {
            requestAuthorization()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleOfflineNotification() {
        // Это уведомление придёт даже если приложение закрыто
        sendNotification(
            title: "ExoWorld Notification",
            body: "This notification works even when app is offline! 🚀",
            delay: 5 // Придёт через 5 секунд
        )
    }
}
