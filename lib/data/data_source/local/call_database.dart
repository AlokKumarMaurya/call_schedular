import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CallDatabase {
  CallDatabase._();

  static final CallDatabase instance = CallDatabase._();

  static const String _databaseName = 'call_scheduler.db';
  static const int _databaseVersion = 1;
  static const String tableName = 'scheduled_calls';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id TEXT PRIMARY KEY,
            contact_name TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            scheduled_at INTEGER NOT NULL,
            status TEXT NOT NULL,
            notes TEXT
          )
        ''');
      },
    );
  }
}