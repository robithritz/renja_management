import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  // Helper method for GET requests
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      return _handleResponse(response);
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
      if (e is ApiConnectionException || e is ApiException) {
        rethrow;
      }
      throw ApiException('GET request failed: $e');
    }
  }

  // Helper method for POST requests
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
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
      if (e is ApiConnectionException || e is ApiException) {
        rethrow;
      }
      throw ApiException('POST request failed: $e');
    }
  }

  // Helper method for PUT requests
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
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
      if (e is ApiConnectionException || e is ApiException) {
        rethrow;
      }
      throw ApiException('PUT request failed: $e');
    }
  }

  // Helper method for DELETE requests
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      return _handleResponse(response);
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
      if (e is ApiConnectionException || e is ApiException) {
        rethrow;
      }
      throw ApiException('DELETE request failed: $e');
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'API Error');
      }
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }
}
