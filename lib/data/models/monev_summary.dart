import '../../shared/enums/hijriah_month.dart';

/// Summary of Monev data for a specific Hijriah month/year
/// Always uses the latest inserted pekan (week) for that month/year
class MonevSummary {
  final HijriahMonth bulanHijriah;
  final int tahunHijriah;
  final int latestWeekNumber; // The latest pekan inserted for this month/year
  final String? shafUuid; // Optional: if filtering by specific shaf

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

  const MonevSummary({
    required this.bulanHijriah,
    required this.tahunHijriah,
    required this.latestWeekNumber,
    this.shafUuid,
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
  });

  /// Get total active MAL
  /// Note: activeMalClassA/B/C/D are subsets of activeMalPu, not additions
  int get totalActiveMal => activeMalPu;

  /// Get total active BN
  /// Note: activeBnClassA/B/C/D are subsets of activeBnPu, not additions
  int get totalActiveBn => activeBnPu;

  /// Get total active members (MAL + BN)
  int get totalActive => totalActiveMal + totalActiveBn;
}
