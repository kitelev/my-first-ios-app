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

    private var timerLabel: UILabel!
    private var stopButton: UIButton!

    private var startTime: Date?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Dark background
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        // Timer label
        timerLabel = UILabel()
        timerLabel.font = UIFont.monospacedSystemFont(ofSize: 48, weight: .bold)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.text = "00:00"
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        // Stop button
        stopButton = UIButton(type: .system)
        stopButton.setTitle("⏹️ Stop Timer", for: .normal)
        stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.layer.cornerRadius = 12
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        view.addSubview(stopButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stopButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 200),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
