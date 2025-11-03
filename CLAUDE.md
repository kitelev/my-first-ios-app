# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS application built with Xcode. The project follows the standard iOS app structure with the main app entry point, content views, and separate test targets for unit and UI testing.

## Building and Running

This project uses Xcode and requires building through Xcode's command-line tools:

```bash
# Build the project
xcodebuild -project my-first-ios-app.xcodeproj -scheme my-first-ios-app -configuration Debug build

# Run unit tests
xcodebuild test -project my-first-ios-app.xcodeproj -scheme my-first-ios-app -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -project my-first-ios-app.xcodeproj -scheme my-first-ios-app -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:my-first-ios-appUITests

# Run a single test class
xcodebuild test -project my-first-ios-app.xcodeproj -scheme my-first-ios-app -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:my-first-ios-appTests/my_first_ios_appTests

# Run a specific test method
xcodebuild test -project my-first-ios-app.xcodeproj -scheme my-first-ios-app -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:my-first-ios-appTests/my_first_ios_appTests/testExample
```

Note: The destination device/simulator name may need to be adjusted based on available simulators. Use `xcrun simctl list devices` to see available options.

## Architecture

**App Entry Point**: `my_first_ios_appApp.swift` contains the `@main` entry point with a `WindowGroup` scene that loads `ContentView`.

**Main View**: `ContentView.swift` is the root SwiftUI view. Currently displays a simple VStack with an image and text.

**Testing Structure**:
- Unit tests: `my-first-ios-appTests/` - Uses XCTest framework with `@testable import`
- UI tests: `my-first-ios-appUITests/` - Uses XCUIApplication for UI automation testing

## Code Conventions

- SwiftUI is the primary UI framework
- Views use declarative syntax with `body` computed properties
- Preview support enabled with `#Preview` macro for SwiftUI views
