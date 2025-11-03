//
//  TimerManager.swift
//  my-first-ios-app
//
//  Created by Claude on 03.11.2025.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedTime: TimeInterval = 0

    private var startTime: Date?
    private var timer: Timer?

    func start() {
        guard !isRunning else { return }

        startTime = Date()
        isRunning = true
        elapsedTime = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        startTime = nil
        elapsedTime = 0
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
}
