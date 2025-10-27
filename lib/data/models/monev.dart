import '../../shared/enums/hijriah_month.dart';
import 'shaf_entity.dart';

class Monev {
  final String uuid;
  final String? shafUuid;
  final String? bengkelName;
  final HijriahMonth bulanHijriah;
  final int tahunHijriah;
  final int weekNumber; // 1..4

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

  final String? narrationMal;
  final String? narrationBn;
  final String? narrationDkw;

  final ShafEntity? shaf; // Full shaf/bengkel entity with totals

  final String createdAt;
  final String updatedAt;

  const Monev({
    required this.uuid,
    required this.shafUuid,
    this.bengkelName,
    required this.bulanHijriah,
    required this.tahunHijriah,
    required this.weekNumber,
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
    this.narrationMal,
    this.narrationBn,
    this.narrationDkw,
    this.shaf,
    required this.createdAt,
    required this.updatedAt,
  });

  Monev copyWith({
    String? uuid,
    String? shafUuid,
    String? bengkelName,
    HijriahMonth? bulanHijriah,
    int? tahunHijriah,
    int? weekNumber,
    int? activeMalPu,
    int? activeMalClassA,
    int? activeMalClassB,
    int? activeMalClassC,
    int? activeMalClassD,
    int? nominalMal,
    int? activeBnPu,
    int? activeBnClassA,
    int? activeBnClassB,
    int? activeBnClassC,
    int? activeBnClassD,
    int? totalNewMember,
    int? totalKdpu,
    String? narrationMal,
    String? narrationBn,
    String? narrationDkw,
    ShafEntity? shaf,
    String? createdAt,
    String? updatedAt,
  }) {
    return Monev(
      uuid: uuid ?? this.uuid,
      shafUuid: shafUuid ?? this.shafUuid,
      bengkelName: bengkelName ?? this.bengkelName,
      bulanHijriah: bulanHijriah ?? this.bulanHijriah,
      tahunHijriah: tahunHijriah ?? this.tahunHijriah,
      weekNumber: weekNumber ?? this.weekNumber,
      activeMalPu: activeMalPu ?? this.activeMalPu,
      activeMalClassA: activeMalClassA ?? this.activeMalClassA,
      activeMalClassB: activeMalClassB ?? this.activeMalClassB,
      activeMalClassC: activeMalClassC ?? this.activeMalClassC,
      activeMalClassD: activeMalClassD ?? this.activeMalClassD,
      nominalMal: nominalMal ?? this.nominalMal,
      activeBnPu: activeBnPu ?? this.activeBnPu,
      activeBnClassA: activeBnClassA ?? this.activeBnClassA,
      activeBnClassB: activeBnClassB ?? this.activeBnClassB,
      activeBnClassC: activeBnClassC ?? this.activeBnClassC,
      activeBnClassD: activeBnClassD ?? this.activeBnClassD,
      totalNewMember: totalNewMember ?? this.totalNewMember,
      totalKdpu: totalKdpu ?? this.totalKdpu,
      narrationMal: narrationMal ?? this.narrationMal,
      narrationBn: narrationBn ?? this.narrationBn,
      narrationDkw: narrationDkw ?? this.narrationDkw,
      shaf: shaf ?? this.shaf,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Monev.fromMap(Map<String, Object?> map) {
    return Monev(
      uuid: map['uuid'] as String,
      shafUuid: map['shafUuid'] as String?,
      bengkelName: map['bengkelName'] as String?,
      bulanHijriah: HijriahMonthX.fromDb((map['bulanHijriah'] ?? '') as String),
      tahunHijriah: (map['tahunHijriah'] as num? ?? 0).toInt(),
      weekNumber: (map['weekNumber'] as num? ?? 1).toInt(),
      activeMalPu: (map['activeMalPu'] as num? ?? 0).toInt(),
      activeMalClassA: (map['activeMalClassA'] as num? ?? 0).toInt(),
      activeMalClassB: (map['activeMalClassB'] as num? ?? 0).toInt(),
      activeMalClassC: (map['activeMalClassC'] as num? ?? 0).toInt(),
      activeMalClassD: (map['activeMalClassD'] as num? ?? 0).toInt(),
      nominalMal: (map['nominalMal'] as num? ?? 0).toInt(),
      activeBnPu: (map['activeBnPu'] as num? ?? 0).toInt(),
      activeBnClassA: (map['activeBnClassA'] as num? ?? 0).toInt(),
      activeBnClassB: (map['activeBnClassB'] as num? ?? 0).toInt(),
      activeBnClassC: (map['activeBnClassC'] as num? ?? 0).toInt(),
      activeBnClassD: (map['activeBnClassD'] as num? ?? 0).toInt(),
      totalNewMember: (map['totalNewMember'] as num? ?? 0).toInt(),
      totalKdpu: (map['totalKdpu'] as num? ?? 0).toInt(),
      narrationMal: map['narrationMal'] as String?,
      narrationBn: map['narrationBn'] as String?,
      narrationDkw: map['narrationDkw'] as String?,
      shaf: map['shaf'] != null
          ? ShafEntity.fromMap(map['shaf'] as Map<String, dynamic>)
          : null,
      createdAt: (map['createdAt'] ?? '') as String,
      updatedAt: (map['updatedAt'] ?? '') as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uuid': uuid,
      'shafUuid': shafUuid,
      'bulanHijriah': bulanHijriah.name,
      'tahunHijriah': tahunHijriah,
      'weekNumber': weekNumber,
      'activeMalPu': activeMalPu,
      'activeMalClassA': activeMalClassA,
      'activeMalClassB': activeMalClassB,
      'activeMalClassC': activeMalClassC,
      'activeMalClassD': activeMalClassD,
      'nominalMal': nominalMal,
      'activeBnPu': activeBnPu,
      'activeBnClassA': activeBnClassA,
      'activeBnClassB': activeBnClassB,
      'activeBnClassC': activeBnClassC,
      'activeBnClassD': activeBnClassD,
      'totalNewMember': totalNewMember,
      'totalKdpu': totalKdpu,
      'narrationMal': narrationMal,
      'narrationBn': narrationBn,
      'narrationDkw': narrationDkw,
      'shaf': shaf?.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() =>
      'Monev(uuid: $uuid, week: $weekNumber, ${bulanHijriah.asString} $tahunHijriah)';
}
