import 'user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    return LoginResponse(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: LoginData.fromMap(map['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.toMap(),
    };
  }
}

class LoginData {
  final String token;
  final User user;

  const LoginData({
    required this.token,
    required this.user,
  });

  factory LoginData.fromMap(Map<String, dynamic> map) {
    return LoginData(
      token: map['token'] as String,
      user: User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'user': user.toMap(),
    };
  }
}

