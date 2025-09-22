import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/renja.dart';
import '../../data/repositories/renja_repository.dart';
import '../../shared/enums/instansi.dart';

class RenjaController extends GetxController {
  RenjaController(this._repo);
  final RenjaRepository _repo;

  final items = <Renja>[].obs;
  final loading = false.obs;

  // UI state
  final selectedInstansi = Rxn<Instansi>();
  final calendarMode = false.obs;
  final currentMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // Derived list with instansi filter applied
  List<Renja> get filteredItems {
    final sel = selectedInstansi.value;
    if (sel == null) return items;
    return items.where((r) => r.instansi == sel).toList();
  }

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
    required String date,
    required String bulanHijriah,
    required int tahunHijriah,
    required int day,
    required String time,
    required String kegiatanDesc,
    required String titikDesc,
    required String pic,
    required String sasaran,
    required String target,
    required String tujuan,
    required double volume,
    required Instansi instansi,
    required int cost,
  }) async {
    final now = DateTime.now().toIso8601String();
    final renja = Renja(
      uuid: const Uuid().v4(),
      date: date,
      bulanHijriah: bulanHijriah,
      tahunHijriah: tahunHijriah,
      day: day,
      time: time,
      kegiatanDesc: kegiatanDesc,
      titikDesc: titikDesc,
      pic: pic,
      sasaran: sasaran,
      target: target,
      tujuan: tujuan,
      volume: volume,
      instansi: instansi,
      cost: cost,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.insert(renja);
    await loadAll();
  }

  Future<void> updateItem(Renja r) async {
    final updated = r.copyWith(updatedAt: DateTime.now().toIso8601String());
    await _repo.update(updated);
    await loadAll();
  }

  Future<void> deleteItem(String uuid) async {
    await _repo.delete(uuid);
    await loadAll();
  }
}
