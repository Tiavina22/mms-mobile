# MMS Mobile App - Setup Guide

This guide will help you set up and run the MMS mobile application.

## Prerequisites

Before starting, make sure you have:

1. **Flutter SDK** installed (version 3.10.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Android Studio** or **Xcode**
   - Android Studio for Android development
   - Xcode for iOS development (macOS only)

3. **Backend Server** running
   - The MMS backend should be running on port 8080
   - See `../mms-backend/README.md` for backend setup

## Step 1: Install Dependencies

Open a terminal in the `mms` folder and run:

```bash
flutter pub get
```

This will download all required packages.

## Step 2: Configure Backend URL

The default configuration is set for localhost. You need to update it based on your setup:

**Edit:** `lib/config/api_config.dart`

### For Android Emulator:

```dart
static const String baseUrl = 'http://10.0.2.2:8080';
static const String wsUrl = 'ws://10.0.2.2:8080/ws';
```

### For iOS Simulator:

```dart
static const String baseUrl = 'http://localhost:8080';
static const String wsUrl = 'ws://localhost:8080/ws';
```

### For Physical Device:

Find your computer's IP address:

**Windows:**
```bash
ipconfig
# Look for IPv4 Address
```

**macOS/Linux:**
```bash
ifconfig
# Look for inet address
```

Then update the config:

```dart
static const String baseUrl = 'http://YOUR_IP:8080';
static const String wsUrl = 'ws://YOUR_IP:8080/ws';
```

Example:
```dart
static const String baseUrl = 'http://192.168.1.100:8080';
static const String wsUrl = 'ws://192.168.1.100:8080/ws';
```

## Step 3: Start the Backend

In a separate terminal, navigate to the backend folder and start the server:

```bash
cd ../mms-backend
go run cmd/main.go
```

You should see:
```
Server starting on :8080
```

## Step 4: Run the Mobile App

### List Available Devices

```bash
flutter devices
```

You should see your connected devices/emulators.

### Run the App

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster)
flutter run --release
```

## Step 5: Test the App

### Create an Account

1. Launch the app
2. Click "Sign Up"
3. Fill in:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `password123`
4. Click "Sign Up"

### Test Chat

1. Create another account (you can use a web browser to call the API directly)
2. Go to "Users" tab
3. Search for the other user
4. Click on the user to open chat
5. Send a message

### Test Groups

1. Go to "Groups" tab
2. Click the "+" button
3. Create a new group
4. Send messages in the group

## Troubleshooting

### Problem: "Connection refused" or "Network error"

**Solution:**
- Check that the backend is running
- Verify the backend URL in `api_config.dart`
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For physical devices, make sure your phone and computer are on the same network

### Problem: "Unable to load assets"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Problem: "WebSocket connection failed"

**Solution:**
- Make sure you're logged in
- Check the WebSocket URL in `api_config.dart`
- Verify the backend WebSocket endpoint is working

### Problem: Gradle build errors (Android)

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: CocoaPods errors (iOS)

**Solution:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

## Development Tools

### Hot Reload

Press `r` in the terminal while the app is running to hot reload.

### Hot Restart

Press `R` in the terminal while the app is running to hot restart.

### Debug Mode

View logs in the terminal where you ran `flutter run`.

### VS Code / Android Studio

You can also run and debug the app directly from your IDE.

## Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS App (macOS only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

## Next Steps

- Customize the UI colors in `lib/main.dart` (theme)
- Add more features (profile editing, notifications, etc.)
- Implement push notifications (FCM for Android, APNs for iOS)
- Add image/file sharing
- Implement message read receipts

## Need Help?

If you encounter any issues:

1. Check the terminal output for error messages
2. Run `flutter doctor` to check your Flutter installation
3. Make sure the backend is running and accessible
4. Verify your device/emulator is connected: `flutter devices`

## Useful Commands

```bash
# Check Flutter installation
flutter doctor

# List devices
flutter devices

# Clean project
flutter clean

# Update dependencies
flutter pub get

# Run tests (if any)
flutter test

# Format code
flutter format lib/

# Analyze code
flutter analyze
```

