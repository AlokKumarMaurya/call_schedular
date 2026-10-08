import 'dart:convert';
import 'dart:typed_data';

import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';
import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class BackupService {
  BackupService(this._repo);

  static const int _backupVersion = 1;

  final CallRepo _repo;

  Future<BackupExportResult> exportBackup() async {
    try {
      final calls = await _repo.getCallList();

      final backup = {
        'backupVersion': _backupVersion,
        'app': 'Callmate',
        'createdAt': DateTime.now().toIso8601String(),
        'calls': calls.map(_callToJson).toList(),
      };

      final jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(backup);

      final bytes = Uint8List.fromList(
        utf8.encode(jsonString),
      );

      final uri = await FilePicker.saveFile(
        dialogTitle: 'Save Callmate Backup',
        fileName: _defaultBackupFileName(),
        bytes: bytes,
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (uri == null) {
        return const BackupExportResult.cancelled();
      }

      AppCrashReporter.instance.log(
        'Callmate backup exported successfully',
      );

      await AppCrashReporter.instance.setKey(
        'backup_export_call_count',
        calls.length,
      );

      return BackupExportResult.success(
        callCount: calls.length,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to export Callmate backup: $e',
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to export Callmate backup',
      );

      return BackupExportResult.failure(
        message: 'Unable to create the backup.',
      );
    }
  }

  Future<BackupRestoreResult> restoreBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: 'Select Callmate Backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) {
        return const BackupRestoreResult.cancelled();
      }

      final file = files.first;

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        return const BackupRestoreResult.failure(
          message: 'The selected backup file is empty.',
        );
      }

      final jsonString = utf8.decode(
        bytes,
        allowMalformed: false,
      );

      final decoded = jsonDecode(jsonString);

      final calls = _parseBackup(decoded);

      if (calls == null) {
        return const BackupRestoreResult.failure(
          message: 'This is not a valid Callmate backup file.',
        );
      }

      final existingCalls = await _repo.getCallList();

      await _cancelNotifications(existingCalls);

      try {
        await _repo.replaceCalls(calls);
      } catch (e) {
        await _rescheduleNotifications(existingCalls);
        rethrow;
      }

      await _rescheduleNotifications(calls);

      AppCrashReporter.instance.log(
        'Callmate backup restored successfully',
      );

      await AppCrashReporter.instance.setKey(
        'backup_restore_call_count',
        calls.length,
      );

      return BackupRestoreResult.success(
        callCount: calls.length,
      );
    } on FormatException catch (e, stackTrace) {
      debugPrint(
        'Invalid Callmate backup format: $e',
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Invalid Callmate backup format',
      );

      return const BackupRestoreResult.failure(
        message: 'The selected file is not valid JSON.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to restore Callmate backup: $e',
      );

      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to restore Callmate backup',
      );

      return const BackupRestoreResult.failure(
        message: 'Unable to restore the backup.',
      );
    }
  }

  Map<String, dynamic> _callToJson(
      CallListEntity call,
      ) {
    return {
      'id': call.id,
      'contactName': call.contactName,
      'phoneNumber': call.phoneNumber,
      'scheduledAt': call.scheduledAt.toIso8601String(),
      'status': call.status.name,
      'notes': call.notes,
      'repeat': call.repeat,
      'reminderMinutesBefore': call.reminderMinutesBefore,
    };
  }

  List<CallListEntity>? _parseBackup(
      dynamic decoded,
      ) {
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final backupVersion = decoded['backupVersion'];

    if (backupVersion != _backupVersion) {
      return null;
    }

    final callsJson = decoded['calls'];

    if (callsJson is! List) {
      return null;
    }

    final calls = <CallListEntity>[];
    final ids = <String>{};

    try {
      for (final item in callsJson) {
        if (item is! Map) {
          return null;
        }

        final map = Map<String, dynamic>.from(item);

        final id = _requiredString(
          map,
          'id',
        );

        final contactName = _requiredString(
          map,
          'contactName',
        );

        final phoneNumber = _requiredString(
          map,
          'phoneNumber',
        );

        final scheduledAtString = _requiredString(
          map,
          'scheduledAt',
        );

        final statusString = _requiredString(
          map,
          'status',
        );

        final repeat = map['repeat'] is String
            ? map['repeat'] as String
            : 'Does not repeat';

        final reminderMinutesBefore =
            _parseReminderMinutes(map['reminderMinutesBefore']);

        final notes = map['notes'] is String
            ? map['notes'] as String?
            : null;

        if (id.isEmpty || ids.contains(id)) {
          return null;
        }

        ids.add(id);

        final scheduledAt = DateTime.parse(
          scheduledAtString,
        );

        final status = CallStatusEntity.values.firstWhere(
              (value) => value.name == statusString,
          orElse: () => throw const FormatException(
            'Invalid call status',
          ),
        );

        calls.add(
          CallListEntity(
            id: id,
            contactName: contactName,
            phoneNumber: phoneNumber,
            scheduledAt: scheduledAt,
            status: status,
            notes: notes,
            repeat: repeat,
            reminderMinutesBefore: reminderMinutesBefore,
          ),
        );
      }
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }

    return calls;
  }

  List<int> _parseReminderMinutes(dynamic value) {
    if (value is! List) {
      return const [0];
    }

    final reminders = value
        .whereType<num>()
        .map((minutes) => minutes.toInt())
        .where((minutes) => minutes >= 0)
        .toSet()
        .toList();

    reminders.sort();

    return reminders.isEmpty ? const [0] : reminders;
  }

  String _requiredString(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];

    if (value is! String) {
      throw const FormatException(
        'Invalid backup field',
      );
    }

    return value;
  }

  Future<void> _cancelNotifications(
      List<CallListEntity> calls,
      ) async {
    for (final call in calls) {
      try {
        await NotificationService.instance.cancelCallReminder(
          call,
        );
      } catch (e) {
        debugPrint(
          'Failed to cancel notification for ${call.id}: $e',
        );
      }
    }
  }

  Future<void> _rescheduleNotifications(
      List<CallListEntity> calls,
      ) async {
    await NotificationService.instance.syncUpcomingCallReminders(
      calls,
    );
  }

  String _defaultBackupFileName() {
    final now = DateTime.now();

    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return 'callmate_backup_${year}_${month}_$day.json';
  }
}

class BackupExportResult {
  const BackupExportResult._({
    required this.isCancelled,
    required this.isSuccess,
    this.callCount = 0,
    this.message,
  });

  const BackupExportResult.success({
    required int callCount,
  }) : this._(
    isCancelled: false,
    isSuccess: true,
    callCount: callCount,
  );

  const BackupExportResult.cancelled()
      : this._(
    isCancelled: true,
    isSuccess: false,
  );

  const BackupExportResult.failure({
    required String message,
  }) : this._(
    isCancelled: false,
    isSuccess: false,
    message: message,
  );

  final bool isCancelled;
  final bool isSuccess;
  final int callCount;
  final String? message;
}

class BackupRestoreResult {
  const BackupRestoreResult._({
    required this.isCancelled,
    required this.isSuccess,
    this.callCount = 0,
    this.message,
  });

  const BackupRestoreResult.success({
    required int callCount,
  }) : this._(
    isCancelled: false,
    isSuccess: true,
    callCount: callCount,
  );

  const BackupRestoreResult.cancelled()
      : this._(
    isCancelled: true,
    isSuccess: false,
  );

  const BackupRestoreResult.failure({
    required String message,
  }) : this._(
    isCancelled: false,
    isSuccess: false,
    message: message,
  );

  final bool isCancelled;
  final bool isSuccess;
  final int callCount;
  final String? message;
}