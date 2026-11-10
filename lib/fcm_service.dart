
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize({
    required Function(RemoteMessage message) onForegroundMessage,
    required Function(RemoteMessage message) onNotificationTap,
    required Function(RemoteMessage message) onInitialMessage,
  }) async {
    // Request notification permission.
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for messages while the app is open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  debugPrint('FCM MESSAGE RECEIVED!');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  onForegroundMessage(message);
});

    // Listen when a user taps a notification
    // while the app is in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(onNotificationTap);

    // Check whether a notification opened the app
    // from a terminated state.
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      onInitialMessage(initialMessage);
    }

    // Retrieve the current device token.
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
  }
}

// Must be a top-level function, not inside a class.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message received: ${message.messageId}');
}
