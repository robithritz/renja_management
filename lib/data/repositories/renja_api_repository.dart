import '../models/renja.dart';
import '../services/api_service.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class RenjaApiRepository {
  // Get all renja with optional filters, sorting, and pagination
  Future<Map<String, dynamic>> getAll({
    String? instansi,
    String? bulanHijriah,
    int? tahunHijriah,
    String? shaf,
    String? shafUuid,
    String sortBy = 'createdAt',
    String sortDir = 'asc',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String endpoint = '/renja';
      final params = <String>[];

      if (instansi != null) params.add('instansi=$instansi');
      if (bulanHijriah != null) params.add('bulanHijriah=$bulanHijriah');
      if (tahunHijriah != null) params.add('tahunHijriah=$tahunHijriah');
      if (shaf != null) params.add('shaf=$shaf');
      if (shafUuid != null) params.add('shafUuid=$shafUuid');
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

      final renjaList = items
          .map((e) => Renja.fromMap(e as Map<String, dynamic>))
          .toList();

      return {'data': renjaList, 'pagination': pagination};
    } on ApiConnectionException catch (e) {
      throw ConnectionException(e.toString());
    } catch (e) {
      throw Exception('Failed to fetch renja: $e');
    }
  }

  // Get renja by UUID
  Future<Renja?> findById(String uuid) async {
    try {
      final response = await ApiService.get('/renja/$uuid');
      final data = response['data'] as Map<String, dynamic>;
      return Renja.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch renja: $e');
    }
  }

  // Create new renja
  Future<Renja> create(Renja renja) async {
    try {
      final response = await ApiService.post('/renja', renja.toMap());
      final data = response['data'] as Map<String, dynamic>;
      return Renja.fromMap(data);
    } catch (e) {
      throw Exception('Failed to create renja: $e');
    }
  }

  // Update renja
  Future<Renja> update(Renja renja) async {
    try {
      final response = await ApiService.put(
        '/renja/${renja.uuid}',
        renja.toMap(),
      );
      final data = response['data'] as Map<String, dynamic>;
      return Renja.fromMap(data);
    } catch (e) {
      throw Exception('Failed to update renja: $e');
    }
  }

  // Update tergelar status
  Future<Renja> updateTergelarStatus(
    String uuid,
    bool? isTergelar,
    String? reasonTidakTergelar,
  ) async {
    try {
      final body = {
        'isTergelar': isTergelar,
        'reasonTidakTergelar': reasonTidakTergelar,
      };
      final response = await ApiService.put('/renja/$uuid', body);
      final data = response['data'] as Map<String, dynamic>;
      return Renja.fromMap(data);
    } catch (e) {
      throw Exception('Failed to update tergelar status: $e');
    }
  }

  // Delete renja
  Future<void> delete(String uuid) async {
    try {
      await ApiService.delete('/renja/$uuid');
    } catch (e) {
      throw Exception('Failed to delete renja: $e');
    }
  }
}
