import 'dart:convert';

import 'package:call_schedular/data/models/call_list_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/entity/call_list_entity.dart';
import 'call_database.dart';

class CallLocalDataSource {
  final CallDatabase _callDatabase;

  CallLocalDataSource(this._callDatabase);

  Future<List<CallListEntity>> getCallList() async {
    final Database db = await _callDatabase.database;

    final result = await db.query(
      CallDatabase.tableName,
      orderBy: 'scheduled_at ASC',
    );

    return result
        .map(
          (map) => CallListModel.fromMap(map).toEntity(),
    )
        .toList();
  }

  Future<void> insertCall(
      CallListEntity entity,
      ) async {
    final Database db = await _callDatabase.database;

    final a = await db.insert(
      CallDatabase.tableName,
      CallListModel.fromEntity(entity).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('=============================== $a');
  }

  Future<void> updateCall(
      CallListEntity entity,
      ) async {
    final Database db = await _callDatabase.database;

    await db.update(
      CallDatabase.tableName,
      CallListModel.fromEntity(entity).toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  Future<void> deleteCall(
      String id,
      ) async {
    final Database db = await _callDatabase.database;

    await db.delete(
      CallDatabase.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> replaceCalls(
      List<CallListEntity> calls,
      ) async {
    final Database db = await _callDatabase.database;

    await db.transaction(
          (transaction) async {
        await transaction.delete(
          CallDatabase.tableName,
        );

        for (final call in calls) {
          await transaction.insert(
            CallDatabase.tableName,
            CallListModel.fromEntity(call).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      },
    );
  }
}

extension CallLocalSyncDataSource on CallLocalDataSource {
  Future<void> enqueueSyncOperation({
    required String callId,
    required String operation,
    required int updatedAt,
    Map<String, Object?>? payload,
  }) async {
    final db = await CallDatabase.instance.database;

    await db.transaction((transaction) async {
      await transaction.delete(
        'sync_outbox',
        where: 'call_id = ?',
        whereArgs: [callId],
      );

      await transaction.insert(
        'sync_outbox',
        {
          'call_id': callId,
          'operation': operation,
          'payload': payload == null ? null : jsonEncode(payload),
          'updated_at': updatedAt,
        },
      );
    });
  }

  Future<List<Map<String, Object?>>> getPendingSyncOperations() async {
    final db = await CallDatabase.instance.database;

    return db.query(
      'sync_outbox',
      orderBy: 'updated_at ASC, id ASC',
    );
  }

  Future<void> removeSyncOperation(int id) async {
    final db = await CallDatabase.instance.database;

    await db.delete(
      'sync_outbox',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
