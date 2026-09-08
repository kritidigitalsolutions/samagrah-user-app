import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:samagrah/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Handling background message: ${message.messageId}');
}

class FCMNotificationService {
  static final FCMNotificationService _instance =
      FCMNotificationService._internal();

  factory FCMNotificationService() => _instance;

  FCMNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<String> _notificationClickController =
      StreamController<String>.broadcast();

  Stream<String> get tokenStream => _tokenController.stream;

  Stream<RemoteMessage> get messageStream => _messageController.stream;

  Stream<String> get notificationClickStream =>
      _notificationClickController.stream;

  String? _fcmToken;
  String? _apnsToken;

  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;

  String? get apnsToken => _apnsToken;

  bool get isInitialized => _isInitialized;

  /// Initialize FCM
  Future<void> initialize() async {
    if (_isInitialized) {
      print('FCM already initialized');
      return;
    }

    try {
      // Firebase initialization
      await Firebase.initializeApp();

      // ----------------------------------------------------------
      // iOS CONFIGURATION
      // ----------------------------------------------------------
      if (Platform.isIOS) {
        await _firebaseMessaging.setAutoInitEnabled(true);

        // Required for foreground notification display on iOS
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Get APNs token
        _apnsToken = await _firebaseMessaging.getAPNSToken();

        print('APNs Token: $_apnsToken');
      }

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Local notifications
      await _initializeLocalNotifications();

      // Request notification permission
      await requestPermission();

      // Get saved FCM token
      final String? savedToken = await getSavedToken();

      if (savedToken != null) {
        _fcmToken = savedToken;
        print('Saved FCM Token: $savedToken');
      } else {
        await getToken();
      }

      // Setup message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;

        _tokenController.add(newToken);

        _saveTokenToPrefs(newToken);

        print('FCM Token refreshed: $newToken');
      });

      _isInitialized = true;

      print('FCM Notification Service initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing FCM: $e');
      print(stackTrace);

      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          requestCriticalPermission: false,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _notificationClickController.add(response.payload!);
        }
      },
    );

    // Android notification channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel androidChannel =
          AndroidNotificationChannel(
            'high_importance_channel',
            'High Importance Notifications',
            description: 'This channel is used for important notifications.',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Request notification permission
  Future<NotificationSettings> requestPermission() async {
    final NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

    print('Notification permission: ${settings.authorizationStatus}');

    // iOS local notification permission
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Refresh APNs token after permission
      _apnsToken = await _firebaseMessaging.getAPNSToken();

      print('APNs Token after permission: $_apnsToken');
    }

    return settings;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      // On iOS, wait until APNs token is available
      if (Platform.isIOS) {
        _apnsToken = await _firebaseMessaging.getAPNSToken();

        if (_apnsToken == null) {
          print('APNs token is not available yet.');
        }
      }

      final String? token = await _firebaseMessaging.getToken();

      _fcmToken = token;

      if (token != null) {
        print('FCM Token: $token');

        _tokenController.add(token);

        await _saveTokenToPrefs(token);
      } else {
        print('FCM token is null');
      }

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup FCM message handlers
  void _setupMessageHandlers() {
    // ----------------------------------------------------------
    // FOREGROUND
    // ----------------------------------------------------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');

      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message notification: ${message.notification}');

        _showLocalNotification(message);
      }

      _messageController.add(message);
    });

    // ----------------------------------------------------------
    // BACKGROUND
    // ----------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background');

      print('Message data: ${message.data}');

      _handleNotificationClick(message);
    });

    // ----------------------------------------------------------
    // TERMINATED
    // ----------------------------------------------------------

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state');

        print('Message data: ${message.data}');

        _handleNotificationClick(message);
      }
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    final AndroidNotification? android = message.notification?.android;

    if (notification == null) {
      return;
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: notificationDetails,
      payload:
          message.data['route'] ??
          message.data['action'] ??
          message.data.toString(),
    );
  }

  /// Handle notification click
  void _handleNotificationClick(RemoteMessage message) {
    final String? route = message.data['route'];

    final String? action = message.data['action'];

    final String value = route ?? action ?? 'default';

    _notificationClickController.add(value);

    print('Notification clicked - Route: $route, Action: $action');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);

    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);

    print('Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();

    _fcmToken = null;

    await _removeTokenFromPrefs();

    print('FCM Token deleted');
  }

  /// Save token
  Future<void> _saveTokenToPrefs(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('fcm_token', token);

    await prefs.setString(
      'fcm_token_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  /// Remove token
  Future<void> _removeTokenFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('fcm_token');

    await prefs.remove('fcm_token_timestamp');
  }

  /// Get saved token
  Future<String?> getSavedToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('fcm_token');
  }

  /// Dispose streams
  void dispose() {
    _tokenController.close();
    _messageController.close();
    _notificationClickController.close();
  }
}
