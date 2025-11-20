# MMS Mobile App

Mobile Messaging System - A real-time chat application built with Flutter.

## Features

- User Authentication (Login/Signup)
- Real-time 1-to-1 Chat
- Group Chat
- User Search
- WebSocket for real-time messaging
- Message encryption (backend)
- Clean and modern UI

## Prerequisites

- Flutter SDK (^3.10.0)
- Dart SDK
- Android Studio / Xcode (for emulators)
- MMS Backend running (see `mms-backend` folder)

## Installation

1. Install dependencies:

```bash
flutter pub get
```

2. Configure backend URL:

Open `lib/config/api_config.dart` and update the base URL:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8080';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.x.x:8080';
```

3. Run the app:

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## Project Structure

```
lib/
├── config/              # Configuration files
│   ├── api_config.dart
│   └── app_config.dart
├── models/              # Data models
│   ├── user.dart
│   ├── message.dart
│   ├── group.dart
│   ├── group_message.dart
│   └── conversation.dart
├── services/            # API and business logic
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── message_service.dart
│   ├── group_service.dart
│   ├── websocket_service.dart
│   └── storage_service.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   ├── group_provider.dart
│   └── user_provider.dart
├── screens/             # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── conversations_tab.dart
│   │   ├── groups_tab.dart
│   │   └── users_tab.dart
│   ├── chat/
│   │   ├── chat_screen.dart
│   │   └── group_chat_screen.dart
│   └── group/
│       └── create_group_screen.dart
├── widgets/             # Reusable widgets
│   └── message_bubble.dart
└── main.dart           # App entry point
```

## Key Dependencies

- `provider` - State management
- `http` - HTTP requests
- `web_socket_channel` - WebSocket connection
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Secure token storage
- `timeago` - Relative time formatting
- `logger` - Logging

## Usage

### 1. Start the Backend

Make sure the backend is running:

```bash
cd ../mms-backend
go run cmd/main.go
```

### 2. Sign Up

1. Launch the app
2. Click "Sign Up"
3. Enter username, email, and password
4. Click "Sign Up"

### 3. Start Chatting

1. Go to "Users" tab
2. Search for a user
3. Click on a user to start chatting
4. Type your message and send

### 4. Create Groups

1. Go to "Groups" tab
2. Click the "+" button
3. Enter group name and description
4. Choose group type (public/private)
5. Click "Create Group"

## Troubleshooting

### Backend Connection Issues

- Make sure the backend is running on port 8080
- Check that the backend URL in `api_config.dart` is correct
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For iOS Simulator, use `localhost`
- For physical devices, use your computer's IP address

### Build Issues

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run again
flutter run
```

### WebSocket Not Connecting

- Ensure the backend WebSocket endpoint is running
- Check that you're logged in (JWT token is required)
- Verify the WebSocket URL in `api_config.dart`

## Development

### Run in Debug Mode

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

### Build Release iOS App

```bash
flutter build ios --release
```

## API Integration

The mobile app communicates with the backend API:

- **Auth**: `/api/auth/signup`, `/api/auth/login`
- **Users**: `/api/users`, `/api/users/:id`
- **Messages**: `/api/messages/*`
- **Groups**: `/api/groups/*`
- **WebSocket**: `/ws?token=<jwt_token>`

See `API_EXAMPLES.md` in the backend folder for detailed API documentation.

## License

This project is private and not licensed for public use.
