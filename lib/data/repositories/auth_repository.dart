import '../models/login_response.dart';
import '../services/api_service.dart';
import '../services/secure_storage_service.dart';

class AuthRepository {
  /// Login with username and password
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        {'username': username, 'password': password},
        includeAuth: false, // Login endpoint doesn't need auth
      );

      final loginResponse = LoginResponse.fromMap(response);

      // Save token and user to local storage
      await SecureStorageService.saveToken(loginResponse.data.token);
      await SecureStorageService.saveUser(loginResponse.data.user);

      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout - clear local storage
  Future<void> logout() async {
    try {
      await SecureStorageService.clearAuth();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return SecureStorageService.isLoggedIn();
  }

  /// Get current user from local storage
  dynamic getCurrentUser() {
    return SecureStorageService.getUser();
  }

  /// Get current token from local storage
  String? getCurrentToken() {
    return SecureStorageService.getToken();
  }
}
