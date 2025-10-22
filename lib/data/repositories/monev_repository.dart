import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/monev.dart';
import '../models/monev_summary.dart';
import '../../shared/enums/hijriah_month.dart';
import 'shaf_repository.dart';

class MonevRepository {
  MonevRepository({ShafRepository? shafRepository})
    : _shafRepository = shafRepository ?? ShafRepository();

  final ShafRepository _shafRepository;

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Monev>> getAll() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.tableMonev,
      orderBy: 'tahun_hijriah DESC, week_number ASC',
    );

    // Fetch all shafs to map shaf_uuid to shaf_name
    final allShafs = await _shafRepository.getAll();
    final shafMap = {for (final shaf in allShafs) shaf.uuid: shaf.rakitName};

    return maps.map((e) {
      final monev = Monev.fromMap(e);
      // Add shaf name if shaf_uuid exists
      if (monev.shafUuid != null && shafMap.containsKey(monev.shafUuid)) {
        return monev.copyWith(shafName: shafMap[monev.shafUuid]);
      }
      return monev;
    }).toList();
  }

  Future<Monev?> findById(String uuid) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.tableMonev,
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Monev.fromMap(maps.first);
  }

  Future<void> insert(Monev e) async {
    final db = await _db;
    await db.insert(
      AppDatabase.tableMonev,
      e.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Monev e) async {
    final db = await _db;
    await db.update(
      AppDatabase.tableMonev,
      e.toMap(),
      where: 'uuid = ?',
      whereArgs: [e.uuid],
    );
  }

  Future<void> delete(String uuid) async {
    final db = await _db;
    await db.delete(
      AppDatabase.tableMonev,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  /// Get summary data for all shafs for a specific Hijriah month/year using the latest pekan
  /// Aggregates data from all shafs that have submitted monev for that month/year
  Future<MonevSummary?> getSummaryByMonthYear(
    HijriahMonth bulan,
    int tahun,
  ) async {
    final db = await _db;

    // Get all shafs' latest pekan data for this month/year
    final maps = await db.rawQuery(
      '''
      SELECT m.* FROM ${AppDatabase.tableMonev} m
      WHERE m.bulan_hijriah = ? AND m.tahun_hijriah = ?
      AND m.week_number = (
        SELECT MAX(week_number) FROM ${AppDatabase.tableMonev}
        WHERE bulan_hijriah = ? AND tahun_hijriah = ? AND shaf_uuid = m.shaf_uuid
      )
      ORDER BY m.shaf_uuid ASC
      ''',
      [bulan.asString, tahun, bulan.asString, tahun],
    );

    if (maps.isEmpty) return null;

    // Aggregate data from all shafs
    int totalActiveMalPu = 0;
    int totalActiveMalClassA = 0;
    int totalActiveMalClassB = 0;
    int totalActiveMalClassC = 0;
    int totalActiveMalClassD = 0;
    int totalNominalMal = 0;
    int totalActiveBnPu = 0;
    int totalActiveBnClassA = 0;
    int totalActiveBnClassB = 0;
    int totalActiveBnClassC = 0;
    int totalActiveBnClassD = 0;
    int totalNewMember = 0;
    int totalKdpu = 0;

    for (final map in maps) {
      final monev = Monev.fromMap(map);
      totalActiveMalPu += monev.activeMalPu;
      totalActiveMalClassA += monev.activeMalClassA;
      totalActiveMalClassB += monev.activeMalClassB;
      totalActiveMalClassC += monev.activeMalClassC;
      totalActiveMalClassD += monev.activeMalClassD;
      totalNominalMal += monev.nominalMal;
      totalActiveBnPu += monev.activeBnPu;
      totalActiveBnClassA += monev.activeBnClassA;
      totalActiveBnClassB += monev.activeBnClassB;
      totalActiveBnClassC += monev.activeBnClassC;
      totalActiveBnClassD += monev.activeBnClassD;
      totalNewMember += monev.totalNewMember;
      totalKdpu += monev.totalKdpu;
    }

    // Get total PU and class totals from all shafs in the Shaf table
    final allShafs = await _shafRepository.getAll();
    int totalPu = 0;
    int totalClassA = 0;
    int totalClassB = 0;
    int totalClassC = 0;
    int totalClassD = 0;
    for (final shaf in allShafs) {
      totalPu += shaf.totalPu;
      totalClassA += shaf.totalClassA;
      totalClassB += shaf.totalClassB;
      totalClassC += shaf.totalClassC;
      totalClassD += shaf.totalClassD;
    }

    // Use the first monev's month/year/week info
    final firstMonev = Monev.fromMap(maps.first);

    return MonevSummary(
      bulanHijriah: firstMonev.bulanHijriah,
      tahunHijriah: firstMonev.tahunHijriah,
      latestWeekNumber: firstMonev.weekNumber,
      shafUuid: null,
      activeMalPu: totalActiveMalPu,
      activeMalClassA: totalActiveMalClassA,
      activeMalClassB: totalActiveMalClassB,
      activeMalClassC: totalActiveMalClassC,
      activeMalClassD: totalActiveMalClassD,
      nominalMal: totalNominalMal,
      activeBnPu: totalActiveBnPu,
      activeBnClassA: totalActiveBnClassA,
      activeBnClassB: totalActiveBnClassB,
      activeBnClassC: totalActiveBnClassC,
      activeBnClassD: totalActiveBnClassD,
      totalNewMember: totalNewMember,
      totalKdpu: totalKdpu,
      totalPu: totalPu,
      totalClassA: totalClassA,
      totalClassB: totalClassB,
      totalClassC: totalClassC,
      totalClassD: totalClassD,
      narrationMal: firstMonev.narrationMal,
      narrationBn: firstMonev.narrationBn,
      narrationDkw: firstMonev.narrationDkw,
    );
  }

  /// Get summary data for a specific Hijriah month/year and shaf using the latest pekan
  Future<MonevSummary?> getSummaryByMonthYearAndShaf(
    HijriahMonth bulan,
    int tahun,
    String shafUuid,
  ) async {
    final db = await _db;

    // Get the latest pekan for this month/year and shaf
    final maps = await db.query(
      AppDatabase.tableMonev,
      where: 'bulan_hijriah = ? AND tahun_hijriah = ? AND shaf_uuid = ?',
      whereArgs: [bulan.asString, tahun, shafUuid],
      orderBy: 'week_number DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final monev = Monev.fromMap(maps.first);
    print(monev.narrationMal);

    // Get total PU and class totals from Shaf
    final shaf = await _shafRepository.findById(shafUuid);
    final totalPu = shaf?.totalPu ?? 0;
    final totalClassA = shaf?.totalClassA ?? 0;
    final totalClassB = shaf?.totalClassB ?? 0;
    final totalClassC = shaf?.totalClassC ?? 0;
    final totalClassD = shaf?.totalClassD ?? 0;

    return MonevSummary(
      bulanHijriah: monev.bulanHijriah,
      tahunHijriah: monev.tahunHijriah,
      latestWeekNumber: monev.weekNumber,
      shafUuid: monev.shafUuid,
      shafName: shaf?.rakitName,
      activeMalPu: monev.activeMalPu,
      activeMalClassA: monev.activeMalClassA,
      activeMalClassB: monev.activeMalClassB,
      activeMalClassC: monev.activeMalClassC,
      activeMalClassD: monev.activeMalClassD,
      nominalMal: monev.nominalMal,
      activeBnPu: monev.activeBnPu,
      activeBnClassA: monev.activeBnClassA,
      activeBnClassB: monev.activeBnClassB,
      activeBnClassC: monev.activeBnClassC,
      activeBnClassD: monev.activeBnClassD,
      totalNewMember: monev.totalNewMember,
      totalKdpu: monev.totalKdpu,
      totalPu: totalPu,
      totalClassA: totalClassA,
      totalClassB: totalClassB,
      totalClassC: totalClassC,
      totalClassD: totalClassD,
      narrationMal: monev.narrationMal,
      narrationBn: monev.narrationBn,
      narrationDkw: monev.narrationDkw,
    );
  }

  /// Get all available shafs for a specific month/year
  Future<List<String>> getAvailableShafsByMonthYear(
    HijriahMonth bulan,
    int tahun,
  ) async {
    final db = await _db;

    final maps = await db.rawQuery(
      'SELECT DISTINCT shaf_uuid FROM ${AppDatabase.tableMonev} '
      'WHERE bulan_hijriah = ? AND tahun_hijriah = ? AND shaf_uuid IS NOT NULL '
      'ORDER BY shaf_uuid ASC',
      [bulan.asString, tahun],
    );

    return maps.map((m) => m['shaf_uuid'] as String).toList();
  }

  /// Get all available Hijriah month/year combinations from the data
  Future<List<Map<String, dynamic>>> getAvailableMonthYears() async {
    final db = await _db;

    final maps = await db.rawQuery(
      'SELECT DISTINCT bulan_hijriah, tahun_hijriah FROM ${AppDatabase.tableMonev} '
      'ORDER BY tahun_hijriah DESC, bulan_hijriah ASC',
    );

    return maps;
  }
}
