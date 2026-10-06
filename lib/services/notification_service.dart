import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone database.
    tz.initializeTimeZones();

    // Get the device's actual timezone.
    final timezoneInfo =
    await FlutterTimezone.getLocalTimezone();

    final location =
    tz.getLocation(timezoneInfo.identifier);

    tz.setLocalLocation(location);

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

  Future<void> scheduleTestNotification() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(
      const Duration(seconds: 30),
    );

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'call_reminders',
        'Call Reminders',
        channelDescription: 'Notifications for scheduled calls',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id: 1000,
      title: 'Call Reminder',
      body: 'This is a scheduled test reminder.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<String> getCurrentTimezone() async {
    final timezoneInfo =
    await FlutterTimezone.getLocalTimezone();

    return timezoneInfo.identifier;
  }
}