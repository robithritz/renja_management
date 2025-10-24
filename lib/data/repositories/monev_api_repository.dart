import '../models/monev.dart';
import '../services/api_service.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class MonevApiRepository {
  // Get all monev with optional filters, sorting, and pagination
  Future<Map<String, dynamic>> getAll({
    String? shafUuid,
    String? bulanHijriah,
    int? tahunHijriah,
    int? weekNumber,
    String sortBy = 'createdAt',
    String sortDir = 'asc',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String endpoint = '/monev';
      final params = <String>[];

      if (shafUuid != null) params.add('shafUuid=$shafUuid');
      if (bulanHijriah != null) params.add('bulanHijriah=$bulanHijriah');
      if (tahunHijriah != null) params.add('tahunHijriah=$tahunHijriah');
      if (weekNumber != null) params.add('weekNumber=$weekNumber');
      params.add('sortBy=$sortBy');
      params.add('sortDir=$sortDir');
      params.add('page=$page');
      params.add('limit=$limit');

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await ApiService.get(endpoint);
      final responseData = response['data'] as Map<String, dynamic>;
      final items = responseData['data'] as List;
      final pagination = responseData['pagination'] as Map<String, dynamic>;

      final monevList = items
          .map((e) => Monev.fromMap(e as Map<String, dynamic>))
          .toList();

      return {'data': monevList, 'pagination': pagination};
    } on ApiConnectionException catch (e) {
      throw ConnectionException(e.toString());
    } catch (e) {
      throw Exception('Failed to fetch monev: $e');
    }
  }

  // Get monev by UUID
  Future<Monev?> findById(String uuid) async {
    try {
      final response = await ApiService.get('/monev/$uuid');
      final data = response['data'] as Map<String, dynamic>;
      return Monev.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch monev: $e');
    }
  }

  // Create new monev
  Future<Monev> create(Monev monev) async {
    try {
      final response = await ApiService.post('/monev', monev.toMap());
      final data = response['data'] as Map<String, dynamic>;
      return Monev.fromMap(data);
    } catch (e) {
      throw Exception('Failed to create monev: $e');
    }
  }

  // Update monev
  Future<Monev> update(Monev monev) async {
    try {
      final response = await ApiService.put(
        '/monev/${monev.uuid}',
        monev.toMap(),
      );
      final data = response['data'] as Map<String, dynamic>;
      return Monev.fromMap(data);
    } catch (e) {
      throw Exception('Failed to update monev: $e');
    }
  }

  // Delete monev
  Future<void> delete(String uuid) async {
    try {
      await ApiService.delete('/monev/$uuid');
    } catch (e) {
      throw Exception('Failed to delete monev: $e');
    }
  }
}
