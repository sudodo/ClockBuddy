# Debugging Calendar Access Issues

## The Problem
Error 1013 indicates the app can't access the calendar database even with proper permissions.

## Solution Options:

### Option 1: Disable App Sandbox (For Testing)
1. In Xcode, select your project
2. Select the ClockBuddy target
3. Go to "Signing & Capabilities"
4. Remove "App Sandbox" capability (click the X)
5. Clean build folder (Shift+Cmd+K)
6. Build and run

### Option 2: Manual Calendar Test
Add this test button to SettingsView to manually trigger event checking:

```swift
Button("Test Calendar Access") {
    Task {
        await model.refreshEvents()
    }
}
```

### Option 3: Use Calendar App Integration
Instead of direct EventKit access, you could:
1. Use AppleScript to query Calendar app
2. Use Shortcuts integration
3. Use a calendar file (.ics) export

### Option 4: Full Disk Access
1. System Preferences → Privacy & Security → Full Disk Access
2. Add ClockBuddy (might help with calendar database access)

## Verification Steps:
1. Open Calendar app and ensure you have events today
2. Check that events are not all-day events
3. Ensure events are in the future (not past)
4. Try creating a test event 1 hour from now

## Alternative Implementation:
If EventKit continues to fail, we could:
- Add manual event entry in settings
- Use a different calendar API
- Create a companion app without sandbox restrictions