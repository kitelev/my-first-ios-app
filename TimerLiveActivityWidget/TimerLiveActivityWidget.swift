//
//  TimerLiveActivityWidget.swift
//  TimerLiveActivityWidget
//
//  Created by Claude on 07.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct TimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        let config = ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI - also shows on Apple Watch
            TimerLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label("Timer", systemImage: "timer")
                        .font(.caption)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.startTime, style: .timer)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        Button(intent: StopTimerIntent()) {
                            Label("Stop", systemImage: "stop.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(context.attributes.startTime, style: .timer)
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "timer")
            }
        }

        // Enable Apple Watch support on iOS 18.0+
        if #available(iOS 18.0, *) {
            return config.supplementalActivityFamilies([.small, .medium])
        } else {
            return config
        }
    }
}

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        // Universal compact layout that works on both iPhone and Apple Watch
        HStack(spacing: 12) {
            // Timer icon
            Image(systemName: "timer")
                .font(.body)
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Timer")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                // Use Text with timer style for automatic updates
                Text(context.attributes.startTime, style: .timer)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            Spacer()

            // Stop button - shows on both iPhone and Apple Watch
            Button(intent: StopTimerIntent()) {
                Image(systemName: "stop.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .activityBackgroundTint(Color.black.opacity(0.8))
    }
}

// App Intent for stopping timer
struct StopTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Timer"

    func perform() async throws -> some IntentResult {
        // Post Darwin notification for cross-process communication
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("ru.kitelev.my-first-ios-app.StopTimer" as CFString),
            nil,
            nil,
            true
        )
        return .result()
    }
}

@main
struct TimerLiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivityWidget()
    }
}
