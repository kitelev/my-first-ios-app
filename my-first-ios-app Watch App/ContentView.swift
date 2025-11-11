//
//  ContentView.swift
//  my-first-ios-app Watch App
//
//  Created by Claude on 12.11.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Timer display
                VStack(spacing: 8) {
                    Text("Timer")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if connectivity.isRunning {
                        if let startTime = connectivity.startTime {
                            // Use Text with timer style for smooth updates
                            Text(startTime, style: .timer)
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .foregroundColor(.green)
                        } else {
                            Text(formattedTime(connectivity.elapsedTime))
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .monospacedDigit()
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("00:00.0")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                    }
                }

                // Start/Stop Timer button
                Button(action: {
                    if connectivity.isRunning {
                        connectivity.sendStopCommand()
                    } else {
                        connectivity.sendStartCommand()
                    }
                }) {
                    Label(
                        connectivity.isRunning ? "Stop Timer" : "Start Timer",
                        systemImage: connectivity.isRunning ? "stop.circle.fill" : "play.circle.fill"
                    )
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(connectivity.isRunning ? .red : .green)

                Divider()
                    .padding(.vertical, 4)

                // Send Notification button
                VStack(spacing: 8) {
                    Text("Push Notification")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        connectivity.sendNotificationRequest()
                    }) {
                        Label("Send Push", systemImage: "bell.badge.fill")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .padding()
        }
    }

    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)

        if hours > 0 {
            return String(format: "%02d:%02d:%02d.%d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchConnectivityManager())
}
