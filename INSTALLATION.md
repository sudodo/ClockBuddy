# ClockBuddy Installation Guide

## Quick Installation (Recommended)

### Step 1: Build in Xcode
1. Open `ClockBuddy.xcodeproj` in Xcode
2. Select your Development Team:
   - Click on the project name in the navigator
   - Select "ClockBuddy" target
   - Go to "Signing & Capabilities"
   - Select your Apple Developer account in "Team"

### Step 2: Create App Icon
1. Open Terminal and navigate to the project folder
2. Run: `swift create_icon.swift`
3. Drag the generated `ClockBuddy.png` to Assets.xcassets > AppIcon

### Step 3: Build and Run
1. Press `Cmd + R` to build and run
2. Grant calendar access when prompted
3. The app will appear as a floating clock

### Step 4: Install to Applications
1. In Xcode, select Product > Archive
2. When Archive completes, click "Distribute App"
3. Choose "Copy App" 
4. Save to your Applications folder

## Alternative: Export for Distribution

### For Personal Use:
1. Product > Archive
2. Distribute App > Copy App
3. Choose "Development" signing
4. Save the .app file
5. Drag to Applications folder

### For Sharing:
1. Product > Archive  
2. Distribute App > Developer ID
3. Choose "Developer ID Application"
4. Export and notarize the app
5. Share the notarized .app file

## First Launch

On first launch:
- Grant calendar access when prompted
- The clock starts in **digital mode without seconds** (default)
- Press `Cmd + ,` to open Settings
- All settings are automatically saved

## Features

- **Cmd + ,** : Open Settings
- **Drag anywhere** : Move the clock window
- **Always on top** : Stays above other windows
- **Calendar sync** : Pink = upcoming events, Cyan = no events

## Troubleshooting

### Calendar Access Issues
- System Preferences > Privacy & Security > Calendars
- Ensure ClockBuddy is checked

### Window Not Visible
- Check all desktop spaces
- Restart the app

## Uninstall

1. Quit ClockBuddy
2. Delete from Applications folder
3. Remove settings: `defaults delete com.dr.sudo.ClockBuddy`