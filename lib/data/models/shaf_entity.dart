class ShafEntity {
  final String uuid;
  final String bengkelName;
  final String bengkelType; // 'rakit', 'asia', 'central'
  final String? asiaUuid; // UUID of parent asia bengkel (for rakit type)
  final String?
  centralUuid; // UUID of parent central bengkel (for rakit or asia type)
  final int totalPu;
  final int totalClassA;
  final int totalClassB;
  final int totalClassC;
  final int totalClassD;
  final String createdAt;
  final String updatedAt;

  const ShafEntity({
    required this.uuid,
    required this.bengkelName,
    required this.bengkelType,
    this.asiaUuid,
    this.centralUuid,
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
    String? bengkelName,
    String? bengkelType,
    String? asiaUuid,
    String? centralUuid,
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
      bengkelName: bengkelName ?? this.bengkelName,
      bengkelType: bengkelType ?? this.bengkelType,
      asiaUuid: asiaUuid ?? this.asiaUuid,
      centralUuid: centralUuid ?? this.centralUuid,
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
      bengkelName: (map['bengkelName'] ?? '') as String,
      bengkelType: (map['bengkelType'] ?? 'rakit') as String,
      asiaUuid: map['asiaUuid'] as String?,
      centralUuid: map['centralUuid'] as String?,
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
      'bengkelName': bengkelName,
      'bengkelType': bengkelType,
      'asiaUuid': asiaUuid,
      'centralUuid': centralUuid,
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
    return 'ShafEntity(uuid: $uuid, bengkelName: $bengkelName, bengkelType: $bengkelType)';
  }
}
