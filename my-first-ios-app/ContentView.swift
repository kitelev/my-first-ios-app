//
//  ContentView.swift
//  my-first-ios-app
//
//  Created by Андрей Кителёв on 03.11.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, ExoWorld!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
