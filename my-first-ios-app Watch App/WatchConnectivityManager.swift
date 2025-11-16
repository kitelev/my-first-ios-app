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

    // Local timer for standalone operation
    private var localTimer: Timer?
    private var localStartTime: Date?

    // Flag to track if we're operating in standalone mode
    private var isStandaloneMode = false

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
        // If WatchConnectivity is not available or we're in standalone mode, use local timer
        if WCSession.default.activationState != .activated || isStandaloneMode {
            print("⚠️ Watch Connectivity not activated or in standalone mode - using local timer")
            startLocalTimer()
            return
        }

        let message = ["action": "start"]
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("✅ Start command sent, reply: \(reply)")
        }) { error in
            print("❌ Error sending start command: \(error.localizedDescription)")
            // Fallback to local timer if iPhone communication fails
            self.startLocalTimer()
        }
    }

    // Send command to iPhone to stop timer
    func sendStopCommand() {
        // If WatchConnectivity is not available or we're in standalone mode, use local timer
        if WCSession.default.activationState != .activated || isStandaloneMode {
            print("⚠️ Watch Connectivity not activated or in standalone mode - using local timer")
            stopLocalTimer()
            return
        }

        let message = ["action": "stop"]
        WCSession.default.sendMessage(message, replyHandler: { reply in
            print("✅ Stop command sent, reply: \(reply)")
        }) { error in
            print("❌ Error sending stop command: \(error.localizedDescription)")
            // Fallback to local timer if iPhone communication fails
            self.stopLocalTimer()
        }
    }

    // Local timer management for standalone operation
    private func startLocalTimer() {
        DispatchQueue.main.async {
            self.isRunning = true
            self.localStartTime = Date()
            self.startTime = self.localStartTime
            self.elapsedTime = 0

            // Start timer to update elapsed time
            self.localTimer?.invalidate()
            self.localTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let start = self.localStartTime {
                    self.elapsedTime = Date().timeIntervalSince(start)
                }
            }
            print("🟢 Local timer started")
        }
    }

    private func stopLocalTimer() {
        DispatchQueue.main.async {
            self.isRunning = false
            self.localTimer?.invalidate()
            self.localTimer = nil
            self.startTime = nil
            self.localStartTime = nil
            self.elapsedTime = 0
            print("🔴 Local timer stopped")
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
