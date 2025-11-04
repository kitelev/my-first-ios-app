//
//  ContentView.swift
//  my-first-ios-app
//
//  Created by Андрей Кителёв on 03.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hi ExoWorld")
                .font(.title)

            Divider()
                .padding(.horizontal)

            VStack(spacing: 20) {
                Text("Timer")
                    .font(.headline)

                Text(timerManager.formattedTime())
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(timerManager.isRunning ? .green : .primary)

                Button(action: {
                    if timerManager.isRunning {
                        timerManager.stop()
                    } else {
                        timerManager.start()
                    }
                }) {
                    Label(
                        timerManager.isRunning ? "Stop Timer" : "Start Timer",
                        systemImage: timerManager.isRunning ? "stop.circle.fill" : "play.circle.fill"
                    )
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(timerManager.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }

            Divider()
                .padding(.horizontal)

            VStack(spacing: 20) {
                Text("Push Notification")
                    .font(.headline)

                Button(action: {
                    if !notificationManager.isAuthorized {
                        notificationManager.requestAuthorization()
                    }
                    notificationManager.scheduleOfflineNotification()
                }) {
                    Label(
                        "Send Push (works offline)",
                        systemImage: "bell.badge.fill"
                    )
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: 250)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }

                if !notificationManager.isAuthorized {
                    Text("Tap to allow notifications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
