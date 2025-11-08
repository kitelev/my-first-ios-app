//
//  TimerActivityAttributes.swift
//  my-first-ios-app
//
//  Created by Claude on 07.11.2025.
//

import ActivityKit
import Foundation

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during the activity
        var elapsedTime: TimeInterval
        var isRunning: Bool
    }

    // Static data that doesn't change during the activity
    var startTime: Date
}
