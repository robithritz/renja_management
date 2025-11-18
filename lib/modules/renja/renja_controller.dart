import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/renja.dart';
import '../../data/models/shaf_entity.dart';
import '../../data/repositories/renja_api_repository.dart';
import '../../data/repositories/shaf_api_repository.dart';
import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class RenjaController extends GetxController {
  RenjaController(this._repo);
  final RenjaApiRepository _repo;

  final items = <Renja>[].obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final connectionError = Rx<String?>(null);

  // Pagination
  final currentPage = 1.obs;
  final pageLimit = 50.obs;
  final totalItems = 0.obs;
  final totalPages = 0.obs;

  bool get hasMorePages => currentPage.value < totalPages.value;

  // UI state
  final selectedInstansi = Rxn<Instansi>();
  final selectedTahunHijriah = Rxn<int>();
  final selectedBulanHijriah = Rxn<HijriahMonth>();
  final selectedTergelar =
      Rxn<bool>(); // null = semua, true/false = filter status
  final selectedShafUuid = Rxn<String>(); // Filter by bengkel/shaf

  // Bengkel filter
  final bengkelList = <ShafEntity>[].obs;
  final loadingBengkel = false.obs;

  final calendarMode = false.obs;
  final currentMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // Cache for items grouped by date (for calendar performance)
  final _itemsByDate = <String, List<Renja>>{}.obs;

  // Derived list with filters applied (instansi, tahun hijriah, bulan hijriah, status)
  List<Renja> get filteredItems {
    Iterable<Renja> list = items;

    final st = selectedTergelar.value;
    if (st != null) {
      list = list.where((r) => r.isTergelar == st);
    }

    return list.toList();
  }

  // Get items for a specific date (cached)
  List<Renja> getItemsByDate(String date) {
    return _itemsByDate[date] ?? [];
  }

  // Rebuild the date cache when items change
  void _rebuildDateCache() {
    final cache = <String, List<Renja>>{};
    for (final item in filteredItems) {
      cache.putIfAbsent(item.date, () => []).add(item);
    }
    _itemsByDate.value = cache;
  }

  @override
  void onInit() {
    super.onInit();
    loadBengkelList();
    loadAll();

    // Listen to filter changes and reload data from API
    ever(selectedInstansi, (_) => loadAll());
    ever(selectedTahunHijriah, (_) => loadAll());
    ever(selectedBulanHijriah, (_) => loadAll());
    ever(selectedShafUuid, (_) => loadAll());
  }

  Future<void> loadBengkelList() async {
    loadingBengkel.value = true;
    try {
      final repo = ShafApiRepository();
      final response = await repo.getAll();
      bengkelList.value = response['data'] as List<ShafEntity>;
    } catch (e) {
      bengkelList.value = [];
    } finally {
      loadingBengkel.value = false;
    }
  }

  Future<void> loadAll() async {
    loading.value = true;
    connectionError.value = null;
    currentPage.value = 1;
    try {
      final response = await _repo.getAll(
        instansi: selectedInstansi.value?.asString,
        // convert the string to enum name
        bulanHijriah: selectedBulanHijriah.value?.name,
        tahunHijriah: selectedTahunHijriah.value,
        shafUuid: selectedShafUuid.value,
        page: currentPage.value,
        limit: pageLimit.value,
      );
      items.value = response['data'] as List<Renja>;
      final pagination = response['pagination'] as Map<String, dynamic>;
      totalItems.value = pagination['total'] as int;
      totalPages.value = pagination['totalPages'] as int;
      _rebuildDateCache();
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
        instansi: selectedInstansi.value?.asString,
        bulanHijriah: selectedBulanHijriah.value?.name,
        tahunHijriah: selectedTahunHijriah.value,
        shafUuid: selectedShafUuid.value,
        page: currentPage.value,
        limit: pageLimit.value,
      );
      final newItems = response['data'] as List<Renja>;
      items.addAll(newItems);
      final pagination = response['pagination'] as Map<String, dynamic>;
      totalItems.value = pagination['total'] as int;
      totalPages.value = pagination['totalPages'] as int;
      _rebuildDateCache();
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
    String? shafUuid,
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
      shafUuid: shafUuid,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.create(renja);
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
