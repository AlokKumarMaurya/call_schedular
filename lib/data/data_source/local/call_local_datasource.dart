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

    return result.map((map) => CallListModel.fromMap(map).toEntity()).toList();
  }

  Future<void> insertCall(CallListEntity entity) async {
    final Database db = await _callDatabase.database;

    await db.insert(
      CallDatabase.tableName,
      CallListModel.fromEntity(entity).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCall(CallListEntity entity) async {
    final Database db = await _callDatabase.database;

    await db.update(
      CallDatabase.tableName,
      CallListModel.fromEntity(entity).toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  Future<void> deleteCall(String id) async {
    final Database db = await _callDatabase.database;

    await db.delete(CallDatabase.tableName, where: 'id = ?', whereArgs: [id]);
  }
}
