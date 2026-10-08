import 'dart:async';

import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'call_reminders';

  static const String _snooze10Minutes = 'snooze_10_minutes';
  static const String _snooze30Minutes = 'snooze_30_minutes';
  static const String _snooze60Minutes = 'snooze_60_minutes';

  static const String _actionReceiverClass =
      'com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver';

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  final StreamController<String> _callNotificationTapController =
  StreamController<String>.broadcast();

  Stream<String> get callNotificationTapStream =>
      _callNotificationTapController.stream;

  String? _initialCallId;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      tz.initializeTimeZones();

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
        onDidReceiveNotificationResponse:
        _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
        notificationTapBackground,
      );

      final launchDetails = await _notifications
          .getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload =
            launchDetails?.notificationResponse?.payload;

        if (payload != null && payload.isNotEmpty) {
          _initialCallId = payload;
        }
      }
    } catch (e, stackTrace) {
      _initialized = false;

      debugPrint(
        'Notification service initialization failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Notification service initialization failed',
      );

      rethrow;
    }
  }

  Future<void> _onNotificationResponse(
      NotificationResponse response,
      ) async {
    final callId = response.payload;

    if (callId == null || callId.isEmpty) {
      return;
    }

    /*
     * Snooze actions are handled separately.
     *
     * The normal notification tap opens the call details.
     */
    if (_isSnoozeAction(response.actionId)) {
      await _handleSnoozeAction(
        response.actionId!,
        callId,
      );

      return;
    }

    _callNotificationTapController.add(callId);
  }

  Future<void> _handleSnoozeAction(
      String actionId,
      String callId,
      ) async {
    final duration = _snoozeDuration(actionId);

    if (duration == null) {
      return;
    }

    try {
      await _scheduleSnoozedNotification(
        callId: callId,
        duration: duration,
      );

      AppCrashReporter.instance.log(
        'Call reminder snoozed for ${duration.inMinutes} minutes',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to snooze notification: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to snooze call reminder',
        information: [
          'callId: $callId',
          'actionId: $actionId',
        ],
      );
    }
  }

  bool _isSnoozeAction(String? actionId) {
    return actionId == _snooze10Minutes ||
        actionId == _snooze30Minutes ||
        actionId == _snooze60Minutes;
  }

  Duration? _snoozeDuration(String actionId) {
    switch (actionId) {
      case _snooze10Minutes:
        return const Duration(minutes: 10);

      case _snooze30Minutes:
        return const Duration(minutes: 30);

      case _snooze60Minutes:
        return const Duration(hours: 1);

      default:
        return null;
    }
  }

  String? consumeInitialCallId() {
    final callId = _initialCallId;

    _initialCallId = null;

    return callId;
  }

  Future<bool> requestNotificationPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return false;
    }

    final enabled =
    await androidPlugin.areNotificationsEnabled();

    if (enabled == true) {
      return true;
    }

    final granted =
    await androidPlugin.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<bool> requestExactAlarmPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return false;
    }

    final canScheduleExact =
    await androidPlugin.canScheduleExactNotifications();

    if (canScheduleExact == true) {
      return true;
    }

    final result =
    await androidPlugin.requestExactAlarmsPermission();

    return result ?? false;
  }

  Future<void> scheduleCallReminder(
      CallListEntity call,
      ) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      call.scheduledAt.year,
      call.scheduledAt.month,
      call.scheduledAt.day,
      call.scheduledAt.hour,
      call.scheduledAt.minute,
    );

    if (!scheduledDate.isAfter(
      tz.TZDateTime.now(tz.local),
    )) {
      return;
    }

    final notificationId =
    _notificationId(call.id);

    final contactName =
    call.contactName.trim().isEmpty
        ? 'Unknown Contact'
        : call.contactName.trim();

    final phoneNumber =
    call.phoneNumber.trim();

    final notificationDetails =
    _notificationDetails();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final canScheduleExact =
        await androidPlugin?.canScheduleExactNotifications() ??
            false;

    final scheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Call $contactName',
        body: phoneNumber.isEmpty
            ? 'You have a scheduled call.'
            : 'Scheduled call with $contactName • $phoneNumber',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: scheduleMode,
        payload: call.id,
      );

      AppCrashReporter.instance.log(
        'Scheduled call reminder using '
            '${canScheduleExact ? 'exact' : 'inexact'} alarm',
      );

      await AppCrashReporter.instance.setKey(
        'notification_schedule_mode',
        canScheduleExact ? 'exact' : 'inexact',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to schedule call reminder: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to schedule call reminder',
        information: [
          'callId: ${call.id}',
          'scheduledAt: ${call.scheduledAt}',
          'scheduleMode: ${canScheduleExact ? 'exact' : 'inexact'}',
        ],
      );

      rethrow;
    }
  }

  Future<void> _scheduleSnoozedNotification({
    required String callId,
    required Duration duration,
  }) async {
    final scheduledDate =
    tz.TZDateTime.now(tz.local).add(duration);

    final notificationId =
    _notificationId(callId);

    final notificationDetails =
    _notificationDetails();

    await _notifications.zonedSchedule(
      id: notificationId,
      title: 'Call reminder',
      body: 'Your snoozed call reminder is ready.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      payload: callId,
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Call Reminders',
        channelDescription:
        'Reminders for scheduled calls',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction(
            _snooze10Minutes,
            '10 min',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _snooze30Minutes,
            '30 min',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _snooze60Minutes,
            '1 hour',
            cancelNotification: true,
            showsUserInterface: false,
          ),
        ],
      ),
    );
  }

  Future<void> cancelCallReminder(
      CallListEntity call,
      ) async {
    final notificationId =
    _notificationId(call.id);

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

  Future<void> syncUpcomingCallReminders(
      List<CallListEntity> calls,
      ) async {
    for (final call in calls) {
      if (call.status != CallStatusEntity.upcoming) {
        continue;
      }

      if (!call.scheduledAt.isAfter(DateTime.now())) {
        continue;
      }

      try {
        await scheduleCallReminder(call);
      } catch (e, stackTrace) {
        debugPrint(
          'Error syncing reminder for ${call.id}: $e',
        );

        await AppCrashReporter.instance.recordError(
          e,
          stackTrace,
          reason: 'Failed to sync call reminder',
          information: [
            'callId: ${call.id}',
          ],
        );
      }
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return false;
    }

    return await androidPlugin.areNotificationsEnabled() ??
        false;
  }

  Future<void> openNotificationSettings() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return;
    }

    await androidPlugin.openAppNotificationSettings();
  }
}

/// Handles notification actions while the application is
/// sleeping or terminated.
///
/// This callback runs on a background isolate.
@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse response,
    ) async {
  final callId = response.payload;

  if (callId == null || callId.isEmpty) {
    return;
  }

  final actionId = response.actionId;

  Duration? duration;

  switch (actionId) {
    case NotificationService._snooze10Minutes:
      duration = const Duration(minutes: 10);
      break;

    case NotificationService._snooze30Minutes:
      duration = const Duration(minutes: 30);
      break;

    case NotificationService._snooze60Minutes:
      duration = const Duration(hours: 1);
      break;
  }

  if (duration == null) {
    return;
  }

  try {
    tz.initializeTimeZones();

    final timezoneInfo =
    await FlutterTimezone.getLocalTimezone();

    final location =
    tz.getLocation(timezoneInfo.identifier);

    tz.setLocalLocation(location);

    final notifications =
    FlutterLocalNotificationsPlugin();

    const notificationDetails =
    NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService._channelId,
        'Call Reminders',
        channelDescription:
        'Reminders for scheduled calls',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction(
            NotificationService._snooze10Minutes,
            '10 min',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            NotificationService._snooze30Minutes,
            '30 min',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            NotificationService._snooze60Minutes,
            '1 hour',
            cancelNotification: true,
            showsUserInterface: false,
          ),
        ],
      ),
    );

    await notifications.zonedSchedule(
      id: _backgroundNotificationId(callId),
      title: 'Call reminder',
      body: 'Your snoozed call reminder is ready.',
      scheduledDate:
      tz.TZDateTime.now(tz.local).add(duration),
      notificationDetails: notificationDetails,
      androidScheduleMode:
      AndroidScheduleMode.inexactAllowWhileIdle,
      payload: callId,
    );
  } catch (e) {
    debugPrint(
      'Background notification snooze failed: $e',
    );
  }
}

int _backgroundNotificationId(String callId) {
  var hash = 0;

  for (final unit in callId.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }

  return hash;
}