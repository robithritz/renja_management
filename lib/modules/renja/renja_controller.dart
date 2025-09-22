import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/renja.dart';
import '../../data/repositories/renja_repository.dart';
import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';

class RenjaController extends GetxController {
  RenjaController(this._repo);
  final RenjaRepository _repo;

  final items = <Renja>[].obs;
  final loading = false.obs;

  // UI state
  final selectedInstansi = Rxn<Instansi>();
  final selectedTahunHijriah = Rxn<int>();
  final selectedBulanHijriah = Rxn<HijriahMonth>();

  final calendarMode = false.obs;
  final currentMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // Derived list with filters applied (instansi, tahun hijriah, bulan hijriah)
  List<Renja> get filteredItems {
    Iterable<Renja> list = items;

    final inst = selectedInstansi.value;
    if (inst != null) {
      list = list.where((r) => r.instansi == inst);
    }
    final th = selectedTahunHijriah.value;
    if (th != null) {
      list = list.where((r) => r.tahunHijriah == th);
    }
    final bln = selectedBulanHijriah.value;
    if (bln != null) {
      list = list.where((r) => r.bulanHijriah == bln);
    }

    return list.toList();
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
    required HijriahMonth bulanHijriah,
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
