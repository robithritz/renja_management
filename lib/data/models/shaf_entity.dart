import 'package:flutter/foundation.dart';

class ShafEntity {
  final String uuid;
  final String asiaName;
  final String rakitName;
  final int totalPu;
  final int totalClassA;
  final int totalClassB;
  final int totalClassC;
  final int totalClassD;
  final String createdAt;
  final String updatedAt;

  const ShafEntity({
    required this.uuid,
    required this.asiaName,
    required this.rakitName,
    required this.totalPu,
    required this.totalClassA,
    required this.totalClassB,
    required this.totalClassC,
    required this.totalClassD,
    required this.createdAt,
    required this.updatedAt,
  });

  ShafEntity copyWith({
    String? uuid,
    String? asiaName,
    String? rakitName,
    int? totalPu,
    int? totalClassA,
    int? totalClassB,
    int? totalClassC,
    int? totalClassD,
    String? createdAt,
    String? updatedAt,
  }) {
    return ShafEntity(
      uuid: uuid ?? this.uuid,
      asiaName: asiaName ?? this.asiaName,
      rakitName: rakitName ?? this.rakitName,
      totalPu: totalPu ?? this.totalPu,
      totalClassA: totalClassA ?? this.totalClassA,
      totalClassB: totalClassB ?? this.totalClassB,
      totalClassC: totalClassC ?? this.totalClassC,
      totalClassD: totalClassD ?? this.totalClassD,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ShafEntity.fromMap(Map<String, Object?> map) {
    return ShafEntity(
      uuid: map['uuid'] as String,
      asiaName: (map['asiaName'] ?? '') as String,
      rakitName: (map['rakitName'] ?? '') as String,
      totalPu: (map['totalPu'] as num? ?? 0).toInt(),
      totalClassA: (map['totalClassA'] as num? ?? 0).toInt(),
      totalClassB: (map['totalClassB'] as num? ?? 0).toInt(),
      totalClassC: (map['totalClassC'] as num? ?? 0).toInt(),
      totalClassD: (map['totalClassD'] as num? ?? 0).toInt(),
      createdAt: (map['createdAt'] ?? '') as String,
      updatedAt: (map['updatedAt'] ?? '') as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uuid': uuid,
      'asiaName': asiaName,
      'rakitName': rakitName,
      'totalPu': totalPu,
      'totalClassA': totalClassA,
      'totalClassB': totalClassB,
      'totalClassC': totalClassC,
      'totalClassD': totalClassD,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ShafEntity(uuid: $uuid, asia: $asiaName, rakit: $rakitName)';
  }
}
