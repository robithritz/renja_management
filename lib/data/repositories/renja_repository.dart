import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/renja.dart';

class RenjaRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Renja>> getAll() async {
    final db = await _db;
    final maps = await db.query(AppDatabase.tableRenja, orderBy: 'date ASC, time ASC');
    return maps.map((e) => Renja.fromMap(e)).toList();
  }

  Future<Renja?> findById(String uuid) async {
    final db = await _db;
    final maps = await db.query(AppDatabase.tableRenja, where: 'uuid = ?', whereArgs: [uuid], limit: 1);
    if (maps.isEmpty) return null;
    return Renja.fromMap(maps.first);
  }

  Future<void> insert(Renja r) async {
    final db = await _db;
    await db.insert(AppDatabase.tableRenja, r.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Renja r) async {
    final db = await _db;
    await db.update(AppDatabase.tableRenja, r.toMap(), where: 'uuid = ?', whereArgs: [r.uuid]);
  }

  Future<void> delete(String uuid) async {
    final db = await _db;
    await db.delete(AppDatabase.tableRenja, where: 'uuid = ?', whereArgs: [uuid]);
  }
}

