import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/shaf_entity.dart';

class ShafRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<ShafEntity>> getAll() async {
    final db = await _db;
    final maps = await db.query(AppDatabase.tableShaf, orderBy: 'asia_name ASC');
    return maps.map((e) => ShafEntity.fromMap(e)).toList();
  }

  Future<ShafEntity?> findById(String uuid) async {
    final db = await _db;
    final maps = await db.query(AppDatabase.tableShaf, where: 'uuid = ?', whereArgs: [uuid], limit: 1);
    if (maps.isEmpty) return null;
    return ShafEntity.fromMap(maps.first);
  }

  Future<void> insert(ShafEntity e) async {
    final db = await _db;
    await db.insert(AppDatabase.tableShaf, e.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(ShafEntity e) async {
    final db = await _db;
    await db.update(AppDatabase.tableShaf, e.toMap(), where: 'uuid = ?', whereArgs: [e.uuid]);
  }

  Future<void> delete(String uuid) async {
    final db = await _db;
    await db.delete(AppDatabase.tableShaf, where: 'uuid = ?', whereArgs: [uuid]);
  }
}

