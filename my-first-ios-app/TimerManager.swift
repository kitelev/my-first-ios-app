//
//  TimerManager.swift
//  my-first-ios-app
//
//  Created by Claude on 03.11.2025.
//

import Foundation
import Combine
import ActivityKit

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0

    private var startTime: Date?
    private var timer: Timer?
    private var liveActivity: Activity<TimerActivityAttributes>?

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
        }

        // Start Live Activity
        startLiveActivity(startTime: now)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        startTime = nil
        elapsedTime = 0

        // End Live Activity
        endLiveActivity()
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
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }

        let attributes = TimerActivityAttributes(startTime: startTime)
        let contentState = TimerActivityAttributes.ContentState(
            elapsedTime: 0,
            isRunning: true
        )

        do {
            liveActivity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
            print("✅ Live Activity started: \(liveActivity?.id ?? "unknown")")
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
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
}
