# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS application built with Xcode. The project includes:
- Main iOS app with timer functionality
- Watch App companion for Apple Watch
- Live Activities support for real-time timer display
- Notification extensions for rich notifications
- Comprehensive CI/CD pipeline with GitHub Actions

The project follows the standard iOS app structure with the main app entry point, content views, and separate test targets for unit, UI, and Watch App testing.

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

## Testing Policy

**IMPORTANT**: Do NOT run tests locally using xcodebuild. Local test execution heavily loads the laptop and causes performance issues.

**Always rely on GitHub Actions CI for testing**:
- All tests run automatically on every push and PR
- CI provides .xcresult artifacts for debugging failures
- Test results are available at: https://github.com/kitelev/my-first-ios-app/actions
- Download artifacts from failed runs to analyze issues in Xcode

If tests fail in CI:
1. Check the Actions tab on GitHub
2. Download the .xcresult artifact from the failed run
3. Open it in Xcode for detailed analysis with screenshots and logs
4. Fix issues based on CI feedback
5. Push changes to re-run tests automatically

## Architecture

**App Entry Point**: `my_first_ios_appApp.swift` contains the `@main` entry point with a `WindowGroup` scene that loads `ContentView`.

**Main View**: `ContentView.swift` is the root SwiftUI view. Currently displays a simple VStack with an image and text.

**Testing Structure**:
- Unit tests: `my-first-ios-appTests/` - Uses XCTest framework with `@testable import`
- UI tests: `my-first-ios-appUITests/` - Uses XCUIApplication for UI automation testing
- Watch App UI tests: `my-first-ios-app Watch AppUITests/` - Tests for watchOS companion app

**Watch App**: `my-first-ios-app Watch App/` contains the watchOS companion app that syncs with the main iOS app via WatchConnectivity framework.

## Code Conventions

- SwiftUI is the primary UI framework
- Views use declarative syntax with `body` computed properties
- Preview support enabled with `#Preview` macro for SwiftUI views
