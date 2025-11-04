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
    @Published var lastNotificationTime: Date?

    init() {
        checkAuthorizationStatus()
        // Удаляем все доставленные уведомления при запуске
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if let error = error {
                    print("❌ Notification authorization error: \(error.localizedDescription)")
                } else {
                    print("✅ Notification authorization: \(granted ? "granted" : "denied")")
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                print("📱 Notification status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }

    func sendInstantNotification(title: String, body: String) {
        guard isAuthorized else {
            print("⚠️ Not authorized, requesting...")
            requestAuthorization()
            return
        }

        // Удаляем pending уведомления
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        // Не используем badge для уменьшения задержек

        // nil trigger = мгновенная доставка
        let request = UNNotificationRequest(
            identifier: "instant-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully at \(Date())")
                DispatchQueue.main.async {
                    self.lastNotificationTime = Date()
                }
            }
        }
    }

    func sendNotification(title: String, body: String, delay: TimeInterval = 2) {
        guard isAuthorized else {
            print("⚠️ Not authorized, requesting...")
            requestAuthorization()
            return
        }

        // Удаляем pending уведомления для избежания дубликатов
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Используем минимум 1 секунду для trigger
        let actualDelay = max(1.0, delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: actualDelay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "delayed-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled for \(actualDelay)s delay at \(Date())")
                DispatchQueue.main.async {
                    self.lastNotificationTime = Date()
                }
            }
        }
    }

    func scheduleOfflineNotification() {
        print("🔔 Scheduling offline notification...")
        // Мгновенное уведомление работает надёжнее
        sendInstantNotification(
            title: "ExoWorld Notification 🚀",
            body: "This works even when app is offline!"
        )
    }
}
