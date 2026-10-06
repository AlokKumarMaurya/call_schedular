import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/domain/repo/call_repo.dart';
import 'package:call_schedular/services/notification_service.dart';
import 'package:flutter/cupertino.dart';

class CallUseCase {
  final CallRepo _repo;

  CallUseCase(this._repo);

  Future<List<CallListEntity>> getCallList() {
    return _repo.getCallList();
  }

  Future<void> addCall(CallListEntity call) {
    return _repo.addCall(call);
  }

  Future<void> updateCall(CallListEntity call) {
    return _repo.updateCall(call);
  }

  Future<void> deleteCall(String id) {
    return _repo.deleteCall(id);
  }

  /// Marks a call as completed.
  ///
  /// If the call is recurring, a new upcoming occurrence
  /// is created automatically.
  Future<CallListEntity> completeCall(
      CallListEntity call,
      ) async {
    final completedCall = call.copyWith(
      status: CallStatusEntity.completed,
    );

    await _repo.updateCall(completedCall);

    if (call.isRecurring) {
      final nextCall = call.createNextOccurrence();

      await _repo.addCall(nextCall);

      try {
        await NotificationService.instance.scheduleCallReminder(
          nextCall,
        );
      } catch (e) {
        debugPrint(
          'Error scheduling next call reminder: $e',
        );
      }
    }

    return completedCall;
  }

  /// Checks all upcoming calls that have passed their
  /// scheduled time.
  ///
  /// Non-recurring:
  ///     upcoming -> missed
  ///
  /// Recurring:
  ///     upcoming -> missed
  ///     create next occurrence
  ///
  /// If multiple recurring occurrences were missed while
  /// the app was closed, all missed occurrences are created
  /// so the history remains accurate.
  Future<List<CallListEntity>> processOverdueCalls(
      List<CallListEntity> calls,
      ) async {
    final now = DateTime.now();

    for (final call in calls) {
      if (call.status != CallStatusEntity.upcoming) {
        continue;
      }

      if (!call.scheduledAt.isBefore(now)) {
        continue;
      }

      if (!call.isRecurring) {
        final missedCall = call.copyWith(
          status: CallStatusEntity.missed,
        );

        await _repo.updateCall(missedCall);

        continue;
      }

      await _processRecurringOverdueCall(
        call,
        now,
      );
    }

    // Read the database again because we may have added
    // multiple new occurrences.
    return _repo.getCallList();
  }

  Future<void> _processRecurringOverdueCall(
      CallListEntity originalCall,
      DateTime now,
      ) async {
    var currentCall = originalCall;

    while (currentCall.scheduledAt.isBefore(now)) {
      final missedCall = currentCall.copyWith(
        status: CallStatusEntity.missed,
      );

      await _repo.updateCall(missedCall);

      final nextCall = currentCall.createNextOccurrence();

      if (!nextCall.scheduledAt.isBefore(now)) {
        // The next occurrence is in the future.
        await _repo.addCall(nextCall);
        break;
      }

      // The next occurrence has already passed too.
      // Save it first, then process it as missed.
      await _repo.addCall(nextCall);

      currentCall = nextCall;
    }
  }
}