import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../models/user.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static final GetStorage _storage = GetStorage();

  /// Save token to local storage
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  /// Get token from local storage
  static String? getToken() {
    return _storage.read<String>(_tokenKey);
  }

  /// Save user to local storage
  static Future<void> saveUser(User user) async {
    await _storage.write(_userKey, jsonEncode(user.toMap()));
  }

  /// Get user from local storage
  static User? getUser() {
    final userJson = _storage.read<String>(_userKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  /// Clear all auth data
  static Future<void> clearAuth() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_userKey);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null;
  }
}

