import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/main.dart';

class NotificationService {
  final FirebaseMessaging? _fcm;
  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static const String _channelId = 'foreground_push_channel';
  static const String _channelName = 'Foreground Notifications';
  static const String _channelDescription =
      'Shows push notifications while app is open';

  NotificationService(this._apiClient)
    : _fcm = isFirebaseAvailable ? FirebaseMessaging.instance : null;

  bool get isAvailable => isFirebaseAvailable && _isInitialized;

  Future<void> initialize() async {
    await _initializeLocalNotifications();

    // Skip initialization if Firebase is not available
    if (!isFirebaseAvailable || _fcm == null) {
      if (kDebugMode) {
        print('⚠ Push notifications disabled: Firebase not available');
      }
      return;
    }

    try {
      // Request permissions (especially for iOS and Android 13+)
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✓ User granted notification permission');
        }

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('Received foreground message: ${message.notification?.title}');
          }
          _showForegroundNotification(message);
        });

        // Handle when app is opened from notification
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('App opened from notification: ${message.data}');
          }
        });

        _isInitialized = true;
      } else {
        if (kDebugMode) {
          print('⚠ User denied notification permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Error initializing notifications: $e');
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  Future<void> registerDevice() async {
    // Skip if Firebase is not available
    if (!isFirebaseAvailable || _fcm == null) {
      if (kDebugMode) {
        print('⚠ Device registration skipped: Firebase not available');
      }
      return;
    }

    try {
      String? token = await _fcm!.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }

        // Send token to backend
        await _apiClient.dio.post('notifications/devices/', data: {
          'registration_id': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
        });

        if (kDebugMode) {
          print('✓ Device registered for push notifications');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Error registering device: $e');
      }
    }
  }
}
