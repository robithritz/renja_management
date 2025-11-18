class User {
  final String uuid;
  final String username;
  final String email;
  final String name;
  final String bengkelUuid;
  final Bengkel bengkel;
  final String role;
  final RoleDetail roleDetail;

  const User({
    required this.uuid,
    required this.username,
    required this.email,
    required this.name,
    required this.bengkelUuid,
    required this.bengkel,
    required this.role,
    required this.roleDetail,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uuid: map['uuid'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      bengkelUuid: map['bengkelUuid'] as String,
      bengkel: Bengkel.fromMap(map['bengkel'] as Map<String, dynamic>),
      role: map['role'] as String,
      roleDetail: RoleDetail.fromMap(map['roleDetail'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'username': username,
      'email': email,
      'name': name,
      'bengkelUuid': bengkelUuid,
      'bengkel': bengkel.toMap(),
      'role': role,
      'roleDetail': roleDetail.toMap(),
    };
  }

  User copyWith({
    String? uuid,
    String? username,
    String? email,
    String? name,
    String? bengkelUuid,
    Bengkel? bengkel,
    String? role,
    RoleDetail? roleDetail,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      bengkelUuid: bengkelUuid ?? this.bengkelUuid,
      bengkel: bengkel ?? this.bengkel,
      role: role ?? this.role,
      roleDetail: roleDetail ?? this.roleDetail,
    );
  }
}

class Bengkel {
  final String uuid;
  final String bengkelName;
  final String bengkelType;
  final String asiaUuid;
  final String centralUuid;

  const Bengkel({
    required this.uuid,
    required this.bengkelName,
    required this.bengkelType,
    required this.asiaUuid,
    required this.centralUuid,
  });

  factory Bengkel.fromMap(Map<String, dynamic> map) {
    return Bengkel(
      uuid: map['uuid'] as String,
      bengkelName: map['bengkelName'] as String,
      bengkelType: map['bengkelType'] as String,
      asiaUuid: map['asiaUuid'] as String? ?? '',
      centralUuid: map['centralUuid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'bengkelName': bengkelName,
      'bengkelType': bengkelType,
      'asiaUuid': asiaUuid,
      'centralUuid': centralUuid,
    };
  }
}

class RoleDetail {
  final int id;
  final String roleName;
  final String name;

  const RoleDetail({
    required this.id,
    required this.roleName,
    required this.name,
  });

  factory RoleDetail.fromMap(Map<String, dynamic> map) {
    return RoleDetail(
      id: map['id'] as int,
      roleName: map['roleName'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roleName': roleName,
      'name': name,
    };
  }
}

