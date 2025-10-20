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
      asiaName: (map['asia_name'] ?? '') as String,
      rakitName: (map['rakit_name'] ?? '') as String,
      totalPu: (map['total_pu'] as num? ?? 0).toInt(),
      totalClassA: (map['total_class_A'] as num? ?? 0).toInt(),
      totalClassB: (map['total_class_B'] as num? ?? 0).toInt(),
      totalClassC: (map['total_class_C'] as num? ?? 0).toInt(),
      totalClassD: (map['total_class_D'] as num? ?? 0).toInt(),
      createdAt: (map['created_at'] ?? '') as String,
      updatedAt: (map['updated_at'] ?? '') as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'uuid': uuid,
      'asia_name': asiaName,
      'rakit_name': rakitName,
      'total_pu': totalPu,
      'total_class_A': totalClassA,
      'total_class_B': totalClassB,
      'total_class_C': totalClassC,
      'total_class_D': totalClassD,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ShafEntity(uuid: $uuid, asia: $asiaName, rakit: $rakitName)';
  }
}

