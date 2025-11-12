//
//  PhoneConnectivityManager.swift
//  my-first-ios-app
//
//  Created by Claude on 12.11.2025.
//

import Foundation
import WatchConnectivity
import Combine

class PhoneConnectivityManager: NSObject, ObservableObject {
    var timerManager: TimerManager?
    var notificationManager: NotificationManager?

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("📱 Phone Connectivity activated")
        }
    }

    // Send timer state to Watch
    func sendTimerState(isRunning: Bool, elapsedTime: TimeInterval, startTime: Date?) {
        guard WCSession.default.activationState == .activated else {
            print("⚠️ Phone Connectivity not activated")
            return
        }

        var context: [String: Any] = [
            "isRunning": isRunning,
            "elapsedTime": elapsedTime
        ]

        if let startTime = startTime {
            context["startTime"] = startTime.timeIntervalSince1970
        }

        do {
            try WCSession.default.updateApplicationContext(context)
            print("📤 Sent timer state to Watch: isRunning=\(isRunning), elapsed=\(elapsedTime)")
        } catch {
            print("❌ Error sending context to Watch: \(error.localizedDescription)")
        }
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Phone Connectivity activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Phone Connectivity activated successfully, state: \(activationState.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⚠️ Phone Connectivity became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("⚠️ Phone Connectivity deactivated, reactivating...")
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                print("📱 Received action from Watch: \(action)")

                switch action {
                case "start":
                    self.timerManager?.start()
                    replyHandler(["status": "started"])

                case "stop":
                    self.timerManager?.stop()
                    replyHandler(["status": "stopped"])

                case "sendNotification":
                    if let notificationManager = self.notificationManager {
                        if !notificationManager.isAuthorized {
                            notificationManager.requestAuthorization()
                        }
                        notificationManager.scheduleOfflineNotification()
                        replyHandler(["status": "notification_sent"])
                    } else {
                        replyHandler(["status": "error", "message": "NotificationManager not available"])
                    }

                default:
                    replyHandler(["status": "unknown_action"])
                }
            } else {
                replyHandler(["status": "error", "message": "No action specified"])
            }
        }
    }
}
