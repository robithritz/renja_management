import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const tableRenja = 'renja';
  static const tableShaf = 'shaf';
  static const tableMonev = 'monev';

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
    is_tergelar INTEGER,
    reason_tidak_tergelar TEXT,
    shaf TEXT,
    created_at TEXT,
    updated_at TEXT
  );
  ''';

  static const _createTableShaf =
      '''
  CREATE TABLE IF NOT EXISTS $tableShaf(
    uuid TEXT PRIMARY KEY,
    asia_name TEXT,
    rakit_name TEXT,
    total_pu INTEGER,
    total_class_A INTEGER,
    total_class_B INTEGER,
    total_class_C INTEGER,
    total_class_D INTEGER,
    created_at TEXT,
    updated_at TEXT
  );
  ''';

  static const _createTableMonev =
      '''
  CREATE TABLE IF NOT EXISTS $tableMonev(
    uuid TEXT PRIMARY KEY,
    shaf_uuid TEXT,
    bulan_hijriah TEXT,
    tahun_hijriah INTEGER,
    week_number INTEGER,
    active_mal_pu INTEGER,
    active_mal_class_A INTEGER,
    active_mal_class_B INTEGER,
    active_mal_class_C INTEGER,
    active_mal_class_D INTEGER,
    nominal_mal INTEGER,
    active_bn_pu INTEGER,
    active_bn_class_A INTEGER,
    active_bn_class_B INTEGER,
    active_bn_class_C INTEGER,
    active_bn_class_D INTEGER,
    total_new_member INTEGER,
    total_kdpu INTEGER,
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
      version: 7,
      onCreate: (db, version) async {
        await db.execute(_createTableRenja);
        await db.execute(_createTableShaf);
        await db.execute(_createTableMonev);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Safe migrations to preserve data
        if (oldVersion < 4) {
          try {
            await db.execute(
              'ALTER TABLE $tableRenja ADD COLUMN is_tergelar INTEGER',
            );
          } catch (_) {}
        }
        if (oldVersion < 5) {
          try {
            await db.execute(
              'ALTER TABLE $tableRenja ADD COLUMN reason_tidak_tergelar TEXT',
            );
          } catch (_) {}
        }
        if (oldVersion < 6) {
          try {
            await db.execute('ALTER TABLE $tableRenja ADD COLUMN shaf TEXT');
          } catch (_) {}
        }
        if (oldVersion < 7) {
          try {
            await db.execute(_createTableShaf);
          } catch (_) {}
          try {
            await db.execute(_createTableMonev);
          } catch (_) {}
        }
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
