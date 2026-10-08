import 'dart:async';
import 'dart:convert';

import 'package:call_schedular/data/data_source/local/call_local_datasource.dart';
import 'package:call_schedular/domain/entity/call_list_entity.dart';
import 'package:call_schedular/services/app_auth_service.dart';
import 'package:call_schedular/services/app_crash_reporter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudSyncService {
  CloudSyncService(this._localDataSource) {
    _authSubscription = AppAuthService.instance.authStateChanges.listen(
      _handleAuthStateChanged,
    );
  }

  final CallLocalDataSource _localDataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _callsSubscription;

  Future<void> _syncQueue = Future<void>.value();
  bool _isInitialSync = true;

  CollectionReference<Map<String, dynamic>>? get _callsCollection {
    final uid = AppAuthService.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('calls');
  }

  void _handleAuthStateChanged(User? user) {
    unawaited(_handleAuthStateChangedAsync(user));
  }

  Future<void> _handleAuthStateChangedAsync(User? user) async {
    await _callsSubscription?.cancel();
    _callsSubscription = null;

    if (user == null) {
      _isInitialSync = true;
      return;
    }

    _isInitialSync = true;

    try {
      await _initialSync();
      await _drainOutbox();

      final collection = _callsCollection;

      if (collection == null) {
        return;
      }

      _callsSubscription = collection.snapshots().listen(
        _handleCloudSnapshot,
        onError: (Object error, StackTrace stackTrace) {
          unawaited(
            AppCrashReporter.instance.recordError(
              error,
              stackTrace,
              reason: 'Cloud call sync listener failed',
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Initial cloud call sync failed',
      );
    }
  }

  Future<void> _initialSync() async {
    final collection = _callsCollection;

    if (collection == null) {
      return;
    }

    final cloudSnapshot = await collection.get();
    final localCalls = await _localDataSource.getCallList();

    if (cloudSnapshot.docs.isEmpty) {
      if (localCalls.isNotEmpty) {
        for (final call in localCalls) {
          await _queueUpsert(call, DateTime.now().millisecondsSinceEpoch);
        }
      }

      _isInitialSync = false;
      return;
    }

    final cloudById = <String, _CloudCall>{};

    for (final document in cloudSnapshot.docs) {
      final call = _callFromDocument(document);
      if (call != null) {
        cloudById[call.id] = call;
      }
    }

    final merged = <String, CallListEntity>{};

    for (final localCall in localCalls) {
      final cloudCall = cloudById[localCall.id];

      if (cloudCall == null ||
          cloudCall.updatedAt <=
              await _localUpdatedAt(localCall.id)) {
        merged[localCall.id] = localCall;
      } else {
        merged[localCall.id] = cloudCall.call;
      }
    }

    for (final cloudCall in cloudById.values) {
      merged.putIfAbsent(cloudCall.id, () => cloudCall.call);
    }

    final result = merged.values.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    await _localDataSource.replaceCalls(result);

    for (final call in result) {
      final cloudCall = cloudById[call.id];
      final localUpdatedAt = await _localUpdatedAt(call.id);

      if (cloudCall == null ||
          localUpdatedAt >= cloudCall.updatedAt) {
        await _queueUpsert(call, localUpdatedAt);
      }
    }

    _isInitialSync = false;
  }

  Future<int> _localUpdatedAt(String callId) async {
    final operations = await _localDataSource.getPendingSyncOperations();

    for (final operation in operations) {
      if (operation['call_id'] == callId) {
        return (operation['updated_at'] as int?) ?? 0;
      }
    }

    return 0;
  }

  Future<void> _queueUpsert(
    CallListEntity call,
    int updatedAt,
  ) async {
    await _localDataSource.enqueueSyncOperation(
      callId: call.id,
      operation: 'upsert',
      updatedAt: updatedAt,
      payload: _callToMap(
        call,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<void> queueUpsert(CallListEntity call) async {
    final updatedAt = DateTime.now().millisecondsSinceEpoch;

    await _queueUpsert(call, updatedAt);
    unawaited(_drainOutbox());
  }

  Future<void> queueDelete(String id) async {
    final updatedAt = DateTime.now().millisecondsSinceEpoch;

    await _localDataSource.enqueueSyncOperation(
      callId: id,
      operation: 'delete',
      updatedAt: updatedAt,
    );

    unawaited(_drainOutbox());
  }

  Future<void> syncAllCalls() async {
    final calls = await _localDataSource.getCallList();

    for (final call in calls) {
      await queueUpsert(call);
    }
  }

  Future<void> retryPendingSync() async {
    final user = AppAuthService.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      if (_isInitialSync) {
        await _initialSync();
        _isInitialSync = false;
      }

      await _drainOutbox();

      if (_callsSubscription == null) {
        final collection = _callsCollection;

        if (collection != null) {
          _callsSubscription = collection.snapshots().listen(
            _handleCloudSnapshot,
            onError: (Object error, StackTrace stackTrace) {
              unawaited(
                AppCrashReporter.instance.recordError(
                  error,
                  stackTrace,
                  reason: 'Cloud call sync listener failed',
                ),
              );
            },
          );
        }
      }
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Retrying pending cloud sync failed',
      );
    }
  }

  Future<void> _drainOutbox() {
    _syncQueue = _syncQueue.then(
      (_) => _drainOutboxInternal(),
    );

    return _syncQueue;
  }

  Future<void> _drainOutboxInternal() async {
    final collection = _callsCollection;

    if (collection == null) {
      return;
    }

    try {
      final operations =
          await _localDataSource.getPendingSyncOperations();

      for (final operation in operations) {
        final operationId = operation['id'] as int;
        final operationType = operation['operation'] as String;
        final callId = operation['call_id'] as String;

        if (operationType == 'delete') {
          await collection.doc(callId).delete();
        } else {
          final payloadString = operation['payload'] as String?;

          if (payloadString == null) {
            await _localDataSource.removeSyncOperation(operationId);
            continue;
          }

          final payload =
              jsonDecode(payloadString) as Map<String, dynamic>;

          await collection.doc(callId).set(payload);
        }

        await _localDataSource.removeSyncOperation(operationId);
      }
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Cloud sync outbox drain failed',
      );
    }
  }

  void _handleCloudSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    unawaited(_applyCloudSnapshot(snapshot));
  }

  Future<void> _applyCloudSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (_isInitialSync) {
      return;
    }

    try {
      for (final change in snapshot.docChanges) {
        final cloudCall = _callFromDocument(change.doc);

        if (change.type == DocumentChangeType.removed) {
          final pendingUpdatedAt =
              await _localUpdatedAt(change.doc.id);

          if (pendingUpdatedAt == 0) {
            await _localDataSource.deleteCall(change.doc.id);
          }
          continue;
        }

        if (cloudCall == null) {
          continue;
        }

        final pendingUpdatedAt =
            await _localUpdatedAt(cloudCall.id);

        if (pendingUpdatedAt > cloudCall.updatedAt) {
          continue;
        }

        await _localDataSource.insertCall(cloudCall.call);
      }

      await _drainOutbox();
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Applying cloud call changes failed',
      );
    }
  }

  Map<String, dynamic> _callToMap(
    CallListEntity call, {
    required int updatedAt,
  }) {
    return {
      'id': call.id,
      'contactName': call.contactName,
      'phoneNumber': call.phoneNumber,
      'scheduledAt': call.scheduledAt.millisecondsSinceEpoch,
      'status': call.status.name,
      'notes': call.notes,
      'repeat': call.repeat,
      'reminderMinutesBefore': call.reminderMinutesBefore,
      'updatedAt': updatedAt,
    };
  }

  _CloudCall? _callFromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      return null;
    }

    final scheduledAt = data['scheduledAt'];
    final rawUpdatedAt = data['updatedAt'];

    if (scheduledAt is! num || rawUpdatedAt == null) {
      return null;
    }

    final updatedAt = rawUpdatedAt is Timestamp
        ? rawUpdatedAt.millisecondsSinceEpoch
        : rawUpdatedAt is num
            ? rawUpdatedAt.toInt()
            : 0;

    if (updatedAt <= 0) {
      return null;
    }

    final status = data['status'] is String
        ? CallStatusEntity.values.firstWhere(
            (value) => value.name == data['status'],
            orElse: () => CallStatusEntity.upcoming,
          )
        : CallStatusEntity.upcoming;

    final reminders = data['reminderMinutesBefore'] is List
        ? (data['reminderMinutesBefore'] as List)
            .whereType<num>()
            .map((value) => value.toInt())
            .where((value) => value >= 0)
            .toSet()
            .toList()
        : const <int>[0];

    final call = CallListEntity(
      id: data['id'] is String && (data['id'] as String).isNotEmpty
          ? data['id'] as String
          : document.id,
      contactName: data['contactName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(
        scheduledAt.toInt(),
      ),
      status: status,
      notes: data['notes'] as String?,
      repeat: data['repeat'] as String? ?? 'Does not repeat',
      reminderMinutesBefore:
          reminders.isEmpty ? const [0] : reminders,
    );

    return _CloudCall(
      call: call,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> debugStatus() {
    return {
      'signedIn': AppAuthService.instance.currentUser != null,
      'initialSync': _isInitialSync,
      'listening': _callsSubscription != null,
    };
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _callsSubscription?.cancel();
    _authSubscription = null;
    _callsSubscription = null;
  }
}

class _CloudCall {
  const _CloudCall({
    required this.call,
    required this.updatedAt,
  });

  final CallListEntity call;
  final int updatedAt;

  String get id => call.id;
}
