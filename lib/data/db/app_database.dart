import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const tableRenja = 'renja';

  static const _createTableRenja =
      '''
  CREATE TABLE IF NOT EXISTS $tableRenja(
    uuid TEXT PRIMARY KEY,
    date TEXT,
    bulan_hijriah TEXT,
    tahun_hijriah INTEGER,
    day INTEGER,
    time TEXT,
    kegiatan_desc TEXT,
    titik_desc TEXT,
    pic TEXT,
    sasaran TEXT,
    target TEXT,
    tujuan TEXT,
    volume REAL,
    instansi TEXT,
    cost INTEGER,
    created_at TEXT,
    updated_at TEXT
  );
  ''';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'renja_management.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(_createTableRenja);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Early reset: drop and recreate table to apply schema changes
        await db.execute('DROP TABLE IF EXISTS $tableRenja');
        await db.execute(_createTableRenja);
      },
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
