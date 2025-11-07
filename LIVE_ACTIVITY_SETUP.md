# Live Activities Setup Guide

This guide will help you complete the setup for Timer Live Activities feature.

## What's Already Done ✅

All the code files have been created:
- `TimerActivityAttributes.swift` - Data model for Live Activity
- `TimerManager.swift` - Updated with Live Activity integration
- `TimerLiveActivityWidget/` - Widget Extension files

## What You Need to Do in Xcode

### Step 1: Add Widget Extension Target

1. Open `my-first-ios-app.xcodeproj` in Xcode
2. Click on the project in the Navigator (top-level item)
3. Click the `+` button at the bottom of the Targets list
4. Select **Widget Extension** from the template picker
5. Configure the extension:
   - Product Name: `TimerLiveActivityWidget`
   - Bundle Identifier: `ru.kitelev.my-first-ios-app.TimerLiveActivityWidget`
   - Include Configuration Intent: ❌ **UNCHECK THIS**
6. Click **Finish**
7. When prompted "Activate scheme?", click **Activate**

### Step 2: Replace Widget Extension Files

1. Delete the default files Xcode created in the `TimerLiveActivityWidget` group:
   - Delete `TimerLiveActivityWidget.swift` (the default one)
   - Delete `TimerLiveActivityWidgetBundle.swift` (if exists)
   - Delete `Assets.xcassets` (optional, not needed)

2. Add the prepared files to the Widget Extension target:
   - Right-click on `TimerLiveActivityWidget` group
   - Select "Add Files to..."
   - Navigate to `TimerLiveActivityWidget/` folder
   - Select `TimerLiveActivityWidget.swift`
   - ✅ Check "Copy items if needed"
   - ✅ Make sure `TimerLiveActivityWidget` target is selected
   - Click **Add**

3. Add `TimerActivityAttributes.swift` to BOTH targets:
   - Select `TimerActivityAttributes.swift` in Navigator
   - In File Inspector (right panel), under "Target Membership"
   - ✅ Check BOTH:
     - `my-first-ios-app`
     - `TimerLiveActivityWidget`

### Step 3: Configure Main App Info.plist

1. Select the main app target (`my-first-ios-app`)
2. Go to **Info** tab
3. Add a new key:
   - Key: `NSSupportsLiveActivities`
   - Type: `Boolean`
   - Value: `YES`

Alternatively, if you have `Info.plist` file:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### Step 4: Update Widget Extension Info.plist

The Widget Extension should already have correct Info.plist from the created file. Verify it contains:
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### Step 5: Configure Deployment Target

1. Select `TimerLiveActivityWidget` target
2. Go to **General** tab
3. Set **Minimum Deployments** to `iOS 16.2` or higher (Live Activities require 16.1+)
4. Make sure main app target also has iOS 16.2+

### Step 6: Add App Group (Required for sharing data)

1. Select main app target (`my-first-ios-app`)
2. Go to **Signing & Capabilities** tab
3. Click `+ Capability`
4. Add **App Groups**
5. Click `+` and create: `group.ru.kitelev.my-first-ios-app`

6. Repeat for Widget Extension target:
   - Select `TimerLiveActivityWidget` target
   - Add **App Groups** capability
   - Select the same group: `group.ru.kitelev.my-first-ios-app`

### Step 7: Build and Test

1. Select `my-first-ios-app` scheme
2. Choose a physical device or simulator (iOS 16.2+)
3. Build and Run (⌘R)
4. Start the timer in the app
5. Lock the screen or go to Home Screen
6. You should see the Live Activity on:
   - Lock Screen
   - Dynamic Island (iPhone 14 Pro and newer)
   - Home Screen (if swiped from top)

## Testing Checklist

- [ ] App builds successfully
- [ ] Timer starts and runs
- [ ] Live Activity appears when timer starts
- [ ] Live Activity shows current time
- [ ] Live Activity updates every 100ms
- [ ] "Stop" button in Live Activity works
- [ ] Live Activity disappears when timer stops
- [ ] Works on Lock Screen
- [ ] Works in Dynamic Island (Pro models)

## Troubleshooting

### "Module 'ActivityKit' not found"
- Make sure deployment target is iOS 16.1+
- Clean build folder (⌘⇧K) and rebuild

### Live Activity doesn't appear
- Check `NSSupportsLiveActivities` is set in main app Info.plist
- Verify Widget Extension target is included in build
- Check device/simulator is iOS 16.2+
- Look for errors in console log

### "areActivitiesEnabled" returns false
- Go to Settings → [Your App] → Allow Live Activities
- Enable Live Activities for your app

### Widget Extension won't compile
- Verify `TimerActivityAttributes.swift` is in BOTH targets
- Check App Groups are configured for both targets
- Verify bundle identifiers are correct

## Architecture

```
Main App (my-first-ios-app)
├── TimerManager.swift          ← Manages timer & Live Activity lifecycle
├── TimerActivityAttributes.swift ← Shared data model
└── ContentView.swift           ← UI (unchanged)

Widget Extension (TimerLiveActivityWidget)
├── TimerLiveActivityWidget.swift ← Live Activity UI definition
├── TimerActivityAttributes.swift ← Shared data model (linked)
└── Info.plist                   ← Widget configuration
```

## How It Works

1. **User starts timer** → `TimerManager.start()` is called
2. **Live Activity starts** → `startLiveActivity()` creates Activity with initial state
3. **Timer updates** → Every 0.1s, `updateLiveActivity()` pushes new elapsed time
4. **UI updates** → Widget Extension renders updated time in Dynamic Island & Lock Screen
5. **User taps Stop** → Widget button triggers `StopTimerIntent` → NotificationCenter → `TimerManager.stop()`
6. **Live Activity ends** → `endLiveActivity()` dismisses the Live Activity

## Features

- ✅ Real-time timer updates (10 times per second)
- ✅ Dynamic Island support (iPhone 14 Pro+)
- ✅ Lock Screen widget
- ✅ Stop button in Live Activity
- ✅ Automatic dismissal when timer stops
- ✅ Clean, monospaced time display

## Next Steps

After setup:
1. Test on physical device for best experience
2. Try with Dynamic Island (if available)
3. Test battery impact with long-running timer
4. Consider adding pause/resume functionality
5. Add haptic feedback for better UX

---

**Note**: Live Activities have limitations:
- Maximum 8 hours duration
- Not available on iPad
- Requires iOS 16.1+
- Dynamic Island requires iPhone 14 Pro or newer
