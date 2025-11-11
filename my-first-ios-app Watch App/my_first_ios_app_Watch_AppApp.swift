//
//  my_first_ios_app_Watch_AppApp.swift
//  my-first-ios-app Watch App
//
//  Created by Claude on 12.11.2025.
//

import SwiftUI

@main
struct my_first_ios_app_Watch_App: App {
    @StateObject private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}
