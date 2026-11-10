# Cloud Courier Mission

A Flutter application demonstrating Firebase Cloud Messaging (FCM) and notification-driven UI updates.

## Features
- Firebase initialization using FlutterFire.
- Foreground notification handling.
- Background notification tap handling.
- Terminated-state notification handling.
- Dynamic image and text updates using custom notification payloads.
- Invalid payload validation with diagnostic feedback.

## Technologies
- Flutter
- Dart
- Firebase Core
- Firebase Cloud Messaging

## Notification Payload

The app supports the following custom data fields:

- `asset`: `campus` or `promo`
- `action`: `update_ui`

Only notification metadata and non-sensitive payload values are used. Form values and personal information are not transmitted.

## Assets
- `assets/campus.jpg`
- `assets/promo.jpg`

## Run the project

```bash
flutter pub get
flutter run
```

## Testing
- T1: Foreground notification.
- T2: Background notification tap.
- T3: Terminated / cold-start notification.
- T4: Invalid payload handling.