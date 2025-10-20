import 'package:flutter/foundation.dart';
import '../../shared/enums/hijriah_month.dart';

class Monev {
  final String uuid;
  final String? shafUuid;
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

  final String createdAt;
  final String updatedAt;

  const Monev({
    required this.uuid,
    required this.shafUuid,
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
    required this.createdAt,
    required this.updatedAt,
  });

  Monev copyWith({
    String? uuid,
    String? shafUuid,
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
    String? createdAt,
    String? updatedAt,
  }) {
    return Monev(
      uuid: uuid ?? this.uuid,
      shafUuid: shafUuid ?? this.shafUuid,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Monev.fromMap(Map<String, Object?> map) {
    return Monev(
      uuid: map['uuid'] as String,
      shafUuid: map['shaf_uuid'] as String?,
      bulanHijriah: HijriahMonthX.fromDb((map['bulan_hijriah'] ?? '') as String),
      tahunHijriah: (map['tahun_hijriah'] as num? ?? 0).toInt(),
      weekNumber: (map['week_number'] as num? ?? 1).toInt(),
      activeMalPu: (map['active_mal_pu'] as num? ?? 0).toInt(),
      activeMalClassA: (map['active_mal_class_A'] as num? ?? 0).toInt(),
      activeMalClassB: (map['active_mal_class_B'] as num? ?? 0).toInt(),
      activeMalClassC: (map['active_mal_class_C'] as num? ?? 0).toInt(),
      activeMalClassD: (map['active_mal_class_D'] as num? ?? 0).toInt(),
      nominalMal: (map['nominal_mal'] as num? ?? 0).toInt(),
      activeBnPu: (map['active_bn_pu'] as num? ?? 0).toInt(),
      activeBnClassA: (map['active_bn_class_A'] as num? ?? 0).toInt(),
      activeBnClassB: (map['active_bn_class_B'] as num? ?? 0).toInt(),
      activeBnClassC: (map['active_bn_class_C'] as num? ?? 0).toInt(),
      activeBnClassD: (map['active_bn_class_D'] as num? ?? 0).toInt(),
      totalNewMember: (map['total_new_member'] as num? ?? 0).toInt(),
      totalKdpu: (map['total_kdpu'] as num? ?? 0).toInt(),
      createdAt: (map['created_at'] ?? '') as String,
      updatedAt: (map['updated_at'] ?? '') as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uuid': uuid,
      'shaf_uuid': shafUuid,
      'bulan_hijriah': bulanHijriah.asString,
      'tahun_hijriah': tahunHijriah,
      'week_number': weekNumber,
      'active_mal_pu': activeMalPu,
      'active_mal_class_A': activeMalClassA,
      'active_mal_class_B': activeMalClassB,
      'active_mal_class_C': activeMalClassC,
      'active_mal_class_D': activeMalClassD,
      'nominal_mal': nominalMal,
      'active_bn_pu': activeBnPu,
      'active_bn_class_A': activeBnClassA,
      'active_bn_class_B': activeBnClassB,
      'active_bn_class_C': activeBnClassC,
      'active_bn_class_D': activeBnClassD,
      'total_new_member': totalNewMember,
      'total_kdpu': totalKdpu,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() => 'Monev(uuid: $uuid, week: $weekNumber, ${bulanHijriah.asString} $tahunHijriah)';
}

