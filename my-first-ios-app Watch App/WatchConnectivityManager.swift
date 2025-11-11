//
//  WatchConnectivityManager.swift
//  my-first-ios-app Watch App
//
//  Created by Claude on 12.11.2025.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var startTime: Date?

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("🔵 Watch Connectivity activated")
        }
    }

    // Send command to iPhone to start timer
    func sendStartCommand() {
        guard WCSession.default.activationState == .activated else {
            print("⚠️ Watch Connectivity not activated")
            return
        }

        let message = ["action": "start"]
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("✅ Start command sent, reply: \(reply)")
        }) { error in
            print("❌ Error sending start command: \(error.localizedDescription)")
        }
    }

    // Send command to iPhone to stop timer
    func sendStopCommand() {
        guard WCSession.default.activationState == .activated else {
            print("⚠️ Watch Connectivity not activated")
            return
        }

        let message = ["action": "stop"]
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("✅ Stop command sent, reply: \(reply)")
        }) { error in
            print("❌ Error sending stop command: \(error.localizedDescription)")
        }
    }

    // Send notification request to iPhone
    func sendNotificationRequest() {
        guard WCSession.default.activationState == .activated else {
            print("⚠️ Watch Connectivity not activated")
            return
        }

        let message = ["action": "sendNotification"]
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("✅ Notification request sent, reply: \(reply)")
        }) { error in
            print("❌ Error sending notification request: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch Connectivity activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Watch Connectivity activated successfully, state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let isRunning = message["isRunning"] as? Bool {
                self.isRunning = isRunning
                print("📱 Received isRunning: \(isRunning)")
            }

            if let elapsedTime = message["elapsedTime"] as? TimeInterval {
                self.elapsedTime = elapsedTime
                print("📱 Received elapsedTime: \(elapsedTime)")
            }

            if let startTimeInterval = message["startTime"] as? TimeInterval {
                self.startTime = Date(timeIntervalSince1970: startTimeInterval)
                print("📱 Received startTime: \(self.startTime!)")
            } else if let running = message["isRunning"] as? Bool, !running {
                self.startTime = nil
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let isRunning = applicationContext["isRunning"] as? Bool {
                self.isRunning = isRunning
            }

            if let elapsedTime = applicationContext["elapsedTime"] as? TimeInterval {
                self.elapsedTime = elapsedTime
            }

            if let startTimeInterval = applicationContext["startTime"] as? TimeInterval {
                self.startTime = Date(timeIntervalSince1970: startTimeInterval)
            } else if let running = applicationContext["isRunning"] as? Bool, !running {
                self.startTime = nil
            }

            print("📱 Received context: isRunning=\(self.isRunning), elapsed=\(self.elapsedTime)")
        }
    }
}
