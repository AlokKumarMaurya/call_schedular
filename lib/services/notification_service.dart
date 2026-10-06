import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );
  }

  Future<bool> requestNotificationPermission() async {
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final granted =
    await androidPlugin?.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> showTestNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'call_reminders',
        'Call Reminders',
        channelDescription: 'Notifications for scheduled calls',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      id: 999,
      title: 'Call Scheduler',
      body: 'Notification service is working.',
      notificationDetails: notificationDetails,
    );
  }
}