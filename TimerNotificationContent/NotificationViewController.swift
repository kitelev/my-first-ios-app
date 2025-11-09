//
//  NotificationViewController.swift
//  TimerNotificationContent
//
//  Created by Claude on 09.11.2025.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!

    private var startTime: Date?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // UI настроен через storyboard
    }

    @IBAction func stopButtonTapped() {
        print("🛑 Stop button tapped in notification content extension")

        // Выполняем действие STOP_TIMER_ACTION
        extensionContext?.performNotificationDefaultAction()
    }

    func didReceive(_ notification: UNNotification) {
        // Получаем время старта из userInfo
        let content = notification.request.content

        if let startTimeInterval = content.userInfo["startTime"] as? TimeInterval {
            startTime = Date(timeIntervalSince1970: startTimeInterval)

            // Запускаем таймер для обновления UI
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateTimerLabel()
            }

            updateTimerLabel()
        } else {
            // Fallback - просто показываем текст из body
            timerLabel?.text = content.body
        }
    }

    private func updateTimerLabel() {
        guard let startTime = startTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60

        if hours > 0 {
            timerLabel?.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timerLabel?.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        timer?.invalidate()
        timer = nil

        if response.actionIdentifier == "STOP_TIMER_ACTION" ||
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            print("🛑 Forwarding stop action to app")
            completion(.dismissAndForwardAction)
        } else {
            completion(.doNotDismiss)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
