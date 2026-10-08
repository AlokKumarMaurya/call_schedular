import 'dart:async';

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
        await _writeAllCalls(localCalls);
      }

      _isInitialSync = false;
      return;
    }

    final cloudCalls = cloudSnapshot.docs
        .map(_callFromDocument)
        .whereType<CallListEntity>()
        .toList();

    final mergedCalls = <String, CallListEntity>{
      for (final call in cloudCalls) call.id: call,
    };

    for (final call in localCalls) {
      mergedCalls.putIfAbsent(call.id, () => call);
    }

    final result = mergedCalls.values.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    await _localDataSource.replaceCalls(result);
    await _writeAllCalls(result);

    _isInitialSync = false;
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
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            final call = _callFromDocument(change.doc);

            if (call != null) {
              await _localDataSource.insertCall(call);
            }
            break;

          case DocumentChangeType.removed:
            await _localDataSource.deleteCall(change.doc.id);
            break;
        }
      }
    } catch (e, stackTrace) {
      await AppCrashReporter.instance.recordError(
        e,
        stackTrace,
        reason: 'Applying cloud call changes failed',
      );
    }
  }

  Future<void> syncCall(CallListEntity call) {
    return _enqueue(() async {
      final collection = _callsCollection;

      if (collection == null) {
        return;
      }

      await collection.doc(call.id).set(_callToMap(call));
    });
  }

  Future<void> deleteCall(String id) {
    return _enqueue(() async {
      final collection = _callsCollection;

      if (collection == null) {
        return;
      }

      await collection.doc(id).delete();
    });
  }

  Future<void> syncAllCalls() {
    return _enqueue(() async {
      final calls = await _localDataSource.getCallList();
      await _writeAllCalls(calls);
    });
  }

  Future<void> _writeAllCalls(List<CallListEntity> calls) async {
    final collection = _callsCollection;

    if (collection == null) {
      return;
    }

    final cloudSnapshot = await collection.get();

    for (var start = 0; start < calls.length; start += 400) {
      final end = (start + 400).clamp(0, calls.length);
      final batch = _firestore.batch();

      for (final call in calls.sublist(start, end)) {
        batch.set(
          collection.doc(call.id),
          _callToMap(call),
        );
      }

      for (final document in cloudSnapshot.docs) {
        final stillExists = calls.any(
          (call) => call.id == document.id,
        );

        if (!stillExists) {
          batch.delete(document.reference);
        }
      }

      await batch.commit();

      if (end >= calls.length) {
        break;
      }
    }

    if (calls.isEmpty && cloudSnapshot.docs.isNotEmpty) {
      final batch = _firestore.batch();

      for (final document in cloudSnapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }
  }

  Future<void> _enqueue(
    Future<void> Function() operation,
  ) {
    _syncQueue = _syncQueue.then(
      (_) async {
        try {
          await operation();
        } catch (e, stackTrace) {
          await AppCrashReporter.instance.recordError(
            e,
            stackTrace,
            reason: 'Cloud call sync operation failed',
          );
        }
      },
    );

    return _syncQueue;
  }

  Map<String, dynamic> _callToMap(CallListEntity call) {
    return {
      'id': call.id,
      'contactName': call.contactName,
      'phoneNumber': call.phoneNumber,
      'scheduledAt': call.scheduledAt.millisecondsSinceEpoch,
      'status': call.status.name,
      'notes': call.notes,
      'repeat': call.repeat,
      'reminderMinutesBefore': call.reminderMinutesBefore,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CallListEntity? _callFromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      return null;
    }

    final scheduledAt = data['scheduledAt'];

    if (scheduledAt is! num) {
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

    return CallListEntity(
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
