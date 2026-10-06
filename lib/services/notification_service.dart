import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'dart:async';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _callNotificationTapController =
      StreamController<String>.broadcast();

  Stream<String> get callNotificationTapStream =>
      _callNotificationTapController.stream;

  String? _initialCallId;

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

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;

      if (payload != null && payload.isNotEmpty) {
        _initialCallId = payload;
      }
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final callId = response.payload;

    if (callId == null || callId.isEmpty) {
      return;
    }

    _callNotificationTapController.add(callId);
  }

  String? consumeInitialCallId() {
    final callId = _initialCallId;

    _initialCallId = null;

    return callId;
  }

  Future<bool> requestNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    if (androidPlugin == null) {
      return false;
    }

    final enabled = await androidPlugin.areNotificationsEnabled();

    if (enabled == true) {
      return true;
    }

    final granted = await androidPlugin.requestNotificationsPermission();

    return granted ?? false;
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
      payload: call.id,
    );
  }

  Future<void> cancelCallReminder(CallListEntity call) async {
    final notificationId = _notificationId(call.id);

    await _notifications.cancel(id: notificationId);
  }

  int _notificationId(String callId) {
    var hash = 0;

    for (final unit in callId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash;
  }

  Future<void> syncUpcomingCallReminders(List<CallListEntity> calls) async {
    for (final call in calls) {
      if (call.status != CallStatusEntity.upcoming) {
        continue;
      }

      if (!call.scheduledAt.isAfter(DateTime.now())) {
        continue;
      }

      try {
        await scheduleCallReminder(call);
      } catch (e) {
        debugPrint('Error syncing reminder for ${call.id}: $e');
      }
    }
  }
}
