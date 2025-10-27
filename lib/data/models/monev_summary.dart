import '../../shared/enums/hijriah_month.dart';

/// Summary of Monev data for a specific Hijriah month/year
/// Always uses the latest inserted pekan (week) for that month/year
class MonevSummary {
  final HijriahMonth bulanHijriah;
  final int tahunHijriah;
  final int latestWeekNumber; // The latest pekan inserted for this month/year
  final String? shafUuid; // Optional: if filtering by specific shaf
  final String? shafName; // Optional: if filtering by specific shaf

  // Aggregated data from latest pekan
  final int activeMalPu;
  final int activeMalClassA;
  final int activeMalClassB;
  final int activeMalClassC;
  final int activeMalClassD;
  final int nominalMal;

  final int activeBnPu;
  final int activeBnClassA;
  final int activeBnClassB;
  final int activeBnClassC;
  final int activeBnClassD;

  final int totalNewMember;
  final int totalKdpu;

  // Total potential members (from Shaf)
  final int totalPu;

  // Shaf class totals (from Shaf table)
  final int totalClassA;
  final int totalClassB;
  final int totalClassC;
  final int totalClassD;

  // Narasi/narration fields
  final String? narrationMal;
  final String? narrationBn;
  final String? narrationDkw;

  const MonevSummary({
    required this.bulanHijriah,
    required this.tahunHijriah,
    required this.latestWeekNumber,
    this.shafUuid,
    this.shafName,
    required this.activeMalPu,
    required this.activeMalClassA,
    required this.activeMalClassB,
    required this.activeMalClassC,
    required this.activeMalClassD,
    required this.nominalMal,
    required this.activeBnPu,
    required this.activeBnClassA,
    required this.activeBnClassB,
    required this.activeBnClassC,
    required this.activeBnClassD,
    required this.totalNewMember,
    required this.totalKdpu,
    required this.totalPu,
    required this.totalClassA,
    required this.totalClassB,
    required this.totalClassC,
    required this.totalClassD,
    this.narrationMal,
    this.narrationBn,
    this.narrationDkw,
  });

  /// Get total active MAL
  /// Note: activeMalClassA/B/C/D are subsets of activeMalPu, not additions
  int get totalActiveMal => activeMalPu;

  /// Get total active BN
  /// Note: activeBnClassA/B/C/D are subsets of activeBnPu, not additions
  int get totalActiveBn => activeBnPu;

  /// Get total active members (MAL + BN)
  int get totalActive => totalActiveMal + totalActiveBn;

  /// Create MonevSummary from API response map
  factory MonevSummary.fromMap(Map<String, dynamic> map) {
    return MonevSummary(
      bulanHijriah: HijriahMonthX.fromDb(map['bulanHijriah'] as String? ?? ''),
      tahunHijriah: map['tahunHijriah'] as int? ?? 0,
      latestWeekNumber: map['latestWeekNumber'] as int? ?? 0,
      shafUuid: map['shafUuid'] as String?,
      shafName: map['shafName'] as String?,
      activeMalPu: map['activeMalPu'] as int? ?? 0,
      activeMalClassA: map['activeMalClassA'] as int? ?? 0,
      activeMalClassB: map['activeMalClassB'] as int? ?? 0,
      activeMalClassC: map['activeMalClassC'] as int? ?? 0,
      activeMalClassD: map['activeMalClassD'] as int? ?? 0,
      nominalMal: map['nominalMal'] as int? ?? 0,
      activeBnPu: map['activeBnPu'] as int? ?? 0,
      activeBnClassA: map['activeBnClassA'] as int? ?? 0,
      activeBnClassB: map['activeBnClassB'] as int? ?? 0,
      activeBnClassC: map['activeBnClassC'] as int? ?? 0,
      activeBnClassD: map['activeBnClassD'] as int? ?? 0,
      totalNewMember: map['totalNewMember'] as int? ?? 0,
      totalKdpu: map['totalKdpu'] as int? ?? 0,
      totalPu: map['totalPu'] as int? ?? 0,
      totalClassA: map['totalClassA'] as int? ?? 0,
      totalClassB: map['totalClassB'] as int? ?? 0,
      totalClassC: map['totalClassC'] as int? ?? 0,
      totalClassD: map['totalClassD'] as int? ?? 0,
      narrationMal: map['narrationMal'] as String?,
      narrationBn: map['narrationBn'] as String?,
      narrationDkw: map['narrationDkw'] as String?,
    );
  }
}
