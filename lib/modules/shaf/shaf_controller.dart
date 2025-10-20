import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/shaf_entity.dart';
import '../../data/repositories/shaf_repository.dart';

class ShafController extends GetxController {
  ShafController(this._repo);
  final ShafRepository _repo;

  final items = <ShafEntity>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    loading.value = true;
    try {
      items.value = await _repo.getAll();
    } finally {
      loading.value = false;
    }
  }

  Future<void> create({
    required String asiaName,
    required String rakitName,
    required int totalPu,
    required int totalClassA,
    required int totalClassB,
    required int totalClassC,
    required int totalClassD,
  }) async {
    final now = DateTime.now().toIso8601String();
    final e = ShafEntity(
      uuid: const Uuid().v4(),
      asiaName: asiaName,
      rakitName: rakitName,
      totalPu: totalPu,
      totalClassA: totalClassA,
      totalClassB: totalClassB,
      totalClassC: totalClassC,
      totalClassD: totalClassD,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.insert(e);
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

