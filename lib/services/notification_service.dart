import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    final location = tz.getLocation(timezoneInfo.identifier);

    tz.setLocalLocation(location);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);
  }

  Future<bool> requestNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestNotificationsPermission();

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
    final scheduledDate = tz.TZDateTime.now(tz.local)
        .add(const Duration(seconds: 30));

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
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    return timezoneInfo.identifier;
  }

  Future<void> scheduleCallReminder(CallListEntity call) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      call.scheduledAt.year,
      call.scheduledAt.month,
      call.scheduledAt.day,
      call.scheduledAt.hour,
      call.scheduledAt.minute,
    );

    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final notificationId = _notificationId(call.id);

    final contactName = call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : call.contactName.trim();

    final phoneNumber = call.phoneNumber.trim();

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'call_reminders',
        'Call Reminders',
        channelDescription: 'Reminders for scheduled calls',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );

    await _notifications.zonedSchedule(
      id: notificationId,
      title: 'Call $contactName',
      body: phoneNumber.isEmpty
          ? 'You have a scheduled call.'
          : 'Scheduled call with $contactName • $phoneNumber',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelCallReminder(CallListEntity call) async {
    final notificationId = _notificationId(call.id);

    await _notifications.cancel(
      id: notificationId,
    );
  }

  int _notificationId(String callId) {
    var hash = 0;

    for (final unit in callId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash;
  }
}
