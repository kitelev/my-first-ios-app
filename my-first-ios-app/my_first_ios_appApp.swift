//
//  my_first_ios_appApp.swift
//  my-first-ios-app
//
//  Created by Андрей Кителёв on 03.11.2025.
//

import SwiftUI
import UserNotifications

// AppDelegate для обработки notification actions
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Устанавливаем delegate для notification center
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Обработка нажатия на action в уведомлении
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📱 Notification action received: \(response.actionIdentifier)")

        if response.actionIdentifier == "STOP_TIMER_ACTION" {
            print("🛑 Stop Timer action pressed from notification")
            // Отправляем сообщение для остановки таймера
            NotificationCenter.default.post(name: NSNotification.Name("StopTimerFromLiveActivity"), object: nil)
        }

        completionHandler()
    }

    // Позволяем показывать уведомления когда приложение в foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Показываем уведомление даже когда приложение открыто
        completionHandler([.banner, .list, .sound])
    }
}

@main
struct my_first_ios_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
