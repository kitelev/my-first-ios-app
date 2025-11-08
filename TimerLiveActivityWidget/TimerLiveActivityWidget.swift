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
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            TimerLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label("Timer", systemImage: "timer")
                        .font(.caption)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(context.state.elapsedTime))
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
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
                Text(formatTimeCompact(context.state.elapsedTime))
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.semibold)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func formatTimeCompact(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Timer icon
            Image(systemName: "timer")
                .font(.title2)
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text("Timer Running")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatTime(context.state.elapsedTime))
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
            }

            Spacer()

            // Stop button
            Button(intent: StopTimerIntent()) {
                HStack(spacing: 4) {
                    Image(systemName: "stop.circle.fill")
                    Text("Stop")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .activityBackgroundTint(Color.black.opacity(0.8))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// App Intent for stopping timer
struct StopTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Timer"

    func perform() async throws -> some IntentResult {
        // Post notification to stop timer
        NotificationCenter.default.post(name: NSNotification.Name("StopTimerFromLiveActivity"), object: nil)
        return .result()
    }
}

@main
struct TimerLiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivityWidget()
    }
}
