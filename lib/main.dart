
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud Courier Mission',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MissionScreen(),
    );
  }
}

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final FCMService _fcmService = FCMService();

  String title = 'Welcome, Courier!';
  String description = 'Waiting for your next mission.';
  String imageAsset = 'assets/campus.jpg';

  // Activity #14 message tracking
  int messageCount = 0;
  String lastHandler = 'None';
  String lastMessageId = 'None';
  String diagnostic = 'Waiting for a message...';

  @override
  void initState() {
    super.initState();
    setupMessaging();
  }

  Future<void> setupMessaging() async {
    await _fcmService.initialize(
      onForegroundMessage: (message) {
        handleMessage(message, 'onMessage');
      },
      onNotificationTap: (message) {
        handleMessage(message, 'onMessageOpenedApp');
      },
      onInitialMessage: (message) {
        handleMessage(message, 'getInitialMessage');
      },
    );
  }

  void handleMessage(RemoteMessage message, String handler) {
    final newTitle = message.notification?.title;
    final newDescription = message.notification?.body;
    final requestedAsset = message.data['asset'];

    String? validAsset;

    // Only allow images that are included in the project.
    if (requestedAsset == 'campus') {
      validAsset = 'assets/campus.jpg';
    } else if (requestedAsset == 'promo') {
      validAsset = 'assets/promo.jpg';
    }

    if (!mounted) return;

    setState(() {
      // Update message tracking information.
      messageCount++;
      lastHandler = handler;
      lastMessageId = message.messageId ?? 'Unavailable';

      // Reject invalid or missing asset values safely.
      if (validAsset == null) {
        diagnostic = requestedAsset == null
            ? 'Invalid payload: missing asset'
            : 'Invalid payload: unsupported asset ($requestedAsset)';

        debugPrint(diagnostic);

        // Keep the previous title, description, and image.
        return;
      }

      // Update the mission screen for a valid payload.
      if (newTitle != null) {
        title = newTitle;
      }

      if (newDescription != null) {
        description = newDescription;
      }

      imageAsset = validAsset;
      diagnostic = 'Payload accepted successfully';

      debugPrint('Message received through: $handler');
      debugPrint('Message ID: $lastMessageId');
      debugPrint('Asset: $requestedAsset');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Courier Mission'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Image.asset(
                imageAsset,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 100,
                  );
                },
              ),

              const SizedBox(height: 16),

              Text(
                description,
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              const Divider(),

              const SizedBox(height: 12),

              const Text(
                'Message Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Shows which FCM handler processed the message.
              _buildInfoRow('Last Handler', lastHandler),

              _buildInfoRow(
                'Messages Received',
                messageCount.toString(),
              ),

              _buildInfoRow('Message ID', lastMessageId),

              const SizedBox(height: 16),

              // Shows whether the payload was accepted or rejected.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: diagnostic.startsWith('Invalid')
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Status: $diagnostic',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: diagnostic.startsWith('Invalid')
                        ? Colors.red.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable display for message information.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
