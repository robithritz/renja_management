import '../models/shaf_entity.dart';
import '../services/api_service.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class ShafApiRepository {
  // Get all shaf with optional sorting and pagination
  Future<Map<String, dynamic>> getAll({
    String sortBy = 'createdAt',
    String sortDir = 'asc',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final endpoint =
          '/shaf?sortBy=$sortBy&sortDir=$sortDir&page=$page&limit=$limit';
      final response = await ApiService.get(endpoint);
      final responseData = response['data'] as Map<String, dynamic>;
      final items = responseData['data'] as List;
      final pagination = responseData['pagination'] as Map<String, dynamic>;

      final shafList = items
          .map((e) => ShafEntity.fromMap(e as Map<String, dynamic>))
          .toList();

      return {'data': shafList, 'pagination': pagination};
    } on ApiConnectionException catch (e) {
      throw ConnectionException(e.toString());
    } catch (e) {
      throw Exception('Failed to fetch shaf: $e');
    }
  }

  // Get shaf by UUID
  Future<ShafEntity?> findById(String uuid) async {
    try {
      final response = await ApiService.get('/shaf/$uuid');
      final data = response['data'] as Map<String, dynamic>;
      return ShafEntity.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch shaf: $e');
    }
  }

  // Create new shaf
  Future<ShafEntity> create(ShafEntity shaf) async {
    try {
      final response = await ApiService.post('/shaf', shaf.toMap());
      final data = response['data'] as Map<String, dynamic>;
      return ShafEntity.fromMap(data);
    } catch (e) {
      throw Exception('Failed to create shaf: $e');
    }
  }

  // Update shaf
  Future<ShafEntity> update(ShafEntity shaf) async {
    try {
      final response = await ApiService.put('/shaf/${shaf.uuid}', shaf.toMap());
      final data = response['data'] as Map<String, dynamic>;
      return ShafEntity.fromMap(data);
    } catch (e) {
      throw Exception('Failed to update shaf: $e');
    }
  }

  // Delete shaf
  Future<void> delete(String uuid) async {
    try {
      await ApiService.delete('/shaf/$uuid');
    } catch (e) {
      throw Exception('Failed to delete shaf: $e');
    }
  }
}
