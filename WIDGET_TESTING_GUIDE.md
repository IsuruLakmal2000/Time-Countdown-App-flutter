# Android Home Screen Widget Testing Guide

## Overview
This guide will help you test the countdown widget functionality on your Android device.

## Prerequisites
- Android device (API level 21 or higher)
- Developer options enabled
- USB debugging enabled

## Installation Steps

1. **Install the APK**
   ```bash
   cd "/Users/isurulakmal/Documents/ios projects/Time Countdown app/Time-Countdown-App-flutter"
   flutter install
   ```

2. **Or manually install the built APK**
   ```bash
   adb install build/app/outputs/flutter-apk/app-debug.apk
   ```

## Testing the Widget

### Step 1: Create a Countdown
1. Open the Time Countdown app
2. Create a new countdown with a title and future date
3. Save the countdown

### Step 2: Access Widget Configuration
1. In the app, tap the widget button in the top-right corner (widget icon)
2. Follow the instructions in the dialog to add the widget to your home screen

### Step 3: Add Widget to Home Screen
1. Long press on your Android home screen
2. Select "Widgets" from the options
3. Find "Time Countdown" in the widget list
4. Drag the "Countdown Widget" to your home screen
5. The widget configuration screen should appear automatically

### Step 4: Configure the Widget
1. Select which countdown you want to display in the widget
2. Tap "Save" to confirm your selection
3. The widget should appear on your home screen showing:
   - Countdown title
   - Days, hours, minutes, and seconds remaining

### Step 5: Test Widget Functionality
1. **Real-time Updates**: The widget should update every 30 seconds
2. **Click Functionality**: Tapping the widget should open the main app
3. **Data Sync**: When you modify countdowns in the app, the widget should reflect changes
4. **Multiple Widgets**: You can add multiple widgets showing different countdowns

## Widget Features

### Display Elements
- **Title**: Shows the countdown name
- **Time Display**: Shows remaining time in format:
  - Days (D)
  - Hours (H) 
  - Minutes (M)
  - Seconds (S)

### Auto-Updates
- Widget updates every 30 seconds
- Countdown calculations happen in real-time
- Widget data syncs when you add/edit/delete countdowns in the app

### Widget Configuration
- Choose from any existing countdown
- Each widget can display a different countdown
- Easy reconfiguration through the widget settings

## Troubleshooting

### Widget Not Updating
1. Check if the app has background permissions
2. Restart the device
3. Remove and re-add the widget

### Widget Shows "No Countdown Selected"
1. Make sure you have created at least one countdown in the app
2. Try reconfiguring the widget

### Widget Configuration Not Opening
1. Ensure the app is installed properly
2. Check if you have sufficient permissions
3. Try adding the widget again

### Multiple Widgets
1. Each widget instance can display a different countdown
2. You can have multiple widgets on different home screens
3. All widgets will update independently

## Technical Details

### Widget Provider
- Native Android App Widget implementation
- Uses JSON data from Flutter shared preferences
- Kotlin-based countdown calculations
- RemoteViews for efficient updates

### Update Mechanism
- Automatic updates every 30 seconds
- Manual updates when countdown data changes in the app
- Efficient battery usage with optimized update intervals

### Data Synchronization
- Widget data stored in shared preferences
- Automatic sync when countdowns are added/edited/deleted
- Cross-platform data handling between Flutter and Android

## Support
If you encounter any issues with the widget functionality, please check:
1. Android version compatibility (API 21+)
2. App permissions
3. Widget provider registration in Android manifest
4. Shared preferences data format

For development debugging, you can check the Android logs:
```bash
adb logcat | grep CountdownWidget
```
