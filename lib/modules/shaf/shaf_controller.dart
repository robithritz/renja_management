import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/shaf_entity.dart';
import '../../data/repositories/shaf_api_repository.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class ShafController extends GetxController {
  ShafController(this._repo);
  final ShafApiRepository _repo;

  ShafApiRepository get repo => _repo;

  final items = <ShafEntity>[].obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final connectionError = Rx<String?>(null);

  // Pagination
  final currentPage = 1.obs;
  final pageLimit = 10.obs;
  final totalItems = 0.obs;
  final totalPages = 0.obs;

  bool get hasMorePages => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    loading.value = true;
    connectionError.value = null;
    currentPage.value = 1;
    try {
      final response = await _repo.getAll(
        page: currentPage.value,
        limit: pageLimit.value,
      );
      items.value = response['data'] as List<ShafEntity>;
      final pagination = response['pagination'] as Map<String, dynamic>;
      totalItems.value = pagination['total'] as int;
      totalPages.value = pagination['totalPages'] as int;
    } on ConnectionException catch (e) {
      connectionError.value = e.toString();
    } catch (e) {
      connectionError.value = 'Failed to load data: $e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMorePages) return;
    loadingMore.value = true;
    try {
      currentPage.value++;
      final response = await _repo.getAll(
        page: currentPage.value,
        limit: pageLimit.value,
      );
      final newItems = response['data'] as List<ShafEntity>;
      items.addAll(newItems);
      final pagination = response['pagination'] as Map<String, dynamic>;
      totalItems.value = pagination['total'] as int;
      totalPages.value = pagination['totalPages'] as int;
    } on ConnectionException catch (e) {
      currentPage.value--;
      connectionError.value = e.toString();
    } catch (e) {
      currentPage.value--;
      connectionError.value = 'Failed to load more data: $e';
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> create({
    required String bengkelName,
    required String bengkelType,
    String? asiaUuid,
    String? centralUuid,
    required int totalPu,
    required int totalClassA,
    required int totalClassB,
    required int totalClassC,
    required int totalClassD,
  }) async {
    final now = DateTime.now().toIso8601String();
    final e = ShafEntity(
      uuid: const Uuid().v4(),
      bengkelName: bengkelName,
      bengkelType: bengkelType,
      asiaUuid: asiaUuid,
      centralUuid: centralUuid,
      totalPu: totalPu,
      totalClassA: totalClassA,
      totalClassB: totalClassB,
      totalClassC: totalClassC,
      totalClassD: totalClassD,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.create(e);
    await loadAll();
  }

  Future<void> updateItem(ShafEntity e) async {
    final updated = e.copyWith(updatedAt: DateTime.now().toIso8601String());
    await _repo.update(updated);
    await loadAll();
  }

  Future<void> deleteItem(String uuid) async {
    await _repo.delete(uuid);
    await loadAll();
  }
}
