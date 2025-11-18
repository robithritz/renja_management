import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'secure_storage_service.dart';

// Custom exception for connection errors
class ApiConnectionException implements Exception {
  final String message;
  ApiConnectionException(this.message);

  @override
  String toString() => message;
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// Custom exception for unauthorized (401) errors
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'http://103.103.22.95:3000/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  /// Build headers with authorization token
  static Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth) {
      final token = SecureStorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle unauthorized (401) error - redirect to login
  static void _handleUnauthorized() {
    SecureStorageService.clearAuth();
    Get.offAllNamed('/login');
  }

  // Helper method for GET requests
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(includeAuth: includeAuth),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on UnauthorizedException {
      _handleUnauthorized();
      rethrow;
    } on SocketException {
      throw ApiConnectionException(
        'Cannot connect to server. Please check your internet connection.',
      );
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        throw ApiConnectionException(
          'Cannot connect to server. Please check your internet connection.',
        );
      }
      if (e is ApiConnectionException ||
          e is ApiException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ApiException('GET request failed: $e');
    }
  }

  // Helper method for POST requests
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (endpoint == '/auth/login' && response.statusCode == 401) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return throw UnauthorizedException(data['message'] ?? 'API Error');
      }
      return _handleResponse(response);
    } on UnauthorizedException {
      _handleUnauthorized();
      rethrow;
    } on SocketException {
      throw ApiConnectionException(
        'Cannot connect to server. Please check your internet connection.',
      );
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        throw ApiConnectionException(
          'Cannot connect to server. Please check your internet connection.',
        );
      }
      if (e is ApiConnectionException ||
          e is ApiException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ApiException('POST request failed: $e');
    }
  }

  // Helper method for PUT requests
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on UnauthorizedException {
      _handleUnauthorized();
      rethrow;
    } on SocketException {
      throw ApiConnectionException(
        'Cannot connect to server. Please check your internet connection.',
      );
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        throw ApiConnectionException(
          'Cannot connect to server. Please check your internet connection.',
        );
      }
      if (e is ApiConnectionException ||
          e is ApiException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ApiException('PUT request failed: $e');
    }
  }

  // Helper method for DELETE requests
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(includeAuth: includeAuth),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on UnauthorizedException {
      _handleUnauthorized();
      rethrow;
    } on SocketException {
      throw ApiConnectionException(
        'Cannot connect to server. Please check your internet connection.',
      );
    } catch (e) {
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('TimeoutException')) {
        throw ApiConnectionException(
          'Cannot connect to server. Please check your internet connection.',
        );
      }
      if (e is ApiConnectionException ||
          e is ApiException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ApiException('DELETE request failed: $e');
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle 401 Unauthorized - redirect to login
      if (response.statusCode == 401) {
        SecureStorageService.clearAuth();
        throw UnauthorizedException('Session expired. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          data['message'] ?? 'API Error',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is UnauthorizedException || e is ApiException) {
        rethrow;
      }
      throw Exception('Failed to parse response: $e');
    }
  }
}
