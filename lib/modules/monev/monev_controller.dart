import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/monev.dart';
import '../../data/models/monev_summary.dart';
import '../../data/models/shaf_entity.dart';
import '../../data/repositories/monev_api_repository.dart';
import '../../data/repositories/monev_repository.dart';
import '../../data/repositories/shaf_api_repository.dart';
import '../../shared/enums/hijriah_month.dart';

class ConnectionException implements Exception {
  final String message;
  ConnectionException(this.message);

  @override
  String toString() => message;
}

class MonevController extends GetxController {
  MonevController(this._apiRepo, this._localRepo);
  final MonevApiRepository _apiRepo;
  final MonevRepository _localRepo;

  final items = <Monev>[].obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final connectionError = Rx<String?>(null);

  // Pagination
  final currentPage = 1.obs;
  final pageLimit = 10.obs;
  final totalItems = 0.obs;
  final totalPages = 0.obs;

  bool get hasMorePages => currentPage.value < totalPages.value;

  // Summary-related observables
  final summaryLoading = false.obs;
  final currentSummary = Rx<MonevSummary?>(null);
  final summaryMonevList = <Monev>[].obs; // Store monev list for narrations
  final availableMonthYears = <Map<String, dynamic>>[].obs;
  final selectedMonth = Rx<HijriahMonth?>(null);
  final selectedYear = Rx<int?>(null);

  // Shaf filter observables
  final availableShafs = <ShafEntity>[].obs;
  final selectedShafUuid = Rx<String?>(null); // null means "all shafs"

  // List page filters
  final bengkelList = <ShafEntity>[].obs;
  final loadingBengkel = false.obs;
  final selectedBengkelUuid = Rxn<String>();
  final selectedBulanHijriah = Rxn<HijriahMonth>();
  final selectedTahunHijriah = Rxn<int>();
  final selectedPekan = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadBengkelList();
    loadAll();
    loadAvailableMonthYears();

    // Listen to filter changes and reload data from API (list page)
    ever(selectedBengkelUuid, (_) => loadAll());
    ever(selectedBulanHijriah, (_) => loadAll());
    ever(selectedTahunHijriah, (_) => loadAll());
    ever(selectedPekan, (_) => loadAll());

    // Listen to summary filter changes and reload summary
    ever(selectedBengkelUuid, (_) => loadSummaryWithFilters());
    ever(selectedBulanHijriah, (_) => loadSummaryWithFilters());
    ever(selectedTahunHijriah, (_) => loadSummaryWithFilters());
    ever(selectedPekan, (_) => loadSummaryWithFilters());
  }

  // Load summary data based on current filters from API
  Future<void> loadSummaryWithFilters() async {
    if (selectedBulanHijriah.value == null ||
        selectedTahunHijriah.value == null) {
      return;
    }

    summaryLoading.value = true;
    try {
      // Fetch all monev data with current filters
      final response = await _apiRepo.getAll(
        shafUuid: selectedBengkelUuid.value,
        bulanHijriah: selectedBulanHijriah.value?.name,
        tahunHijriah: selectedTahunHijriah.value,
        weekNumber: selectedPekan.value,
        limit: 1000, // Get all records for summary calculation
      );

      final monevList = response['data'] as List<Monev>? ?? [];

      if (monevList.isEmpty) {
        currentSummary.value = null;
        summaryMonevList.value = [];
        return;
      }

      // Store the monev list for narrations
      summaryMonevList.value = monevList;
      // Calculate summary from the fetched data
      currentSummary.value = _calculateSummary(monevList);
    } catch (e) {
      currentSummary.value = null;
    } finally {
      summaryLoading.value = false;
    }
  }

  // Calculate summary from monev list
  MonevSummary _calculateSummary(List<Monev> monevList) {
    if (monevList.isEmpty) {
      throw Exception('No data to summarize');
    }

    final firstMonev = monevList.first;

    // Aggregate all values
    int totalActiveMalPu = 0;
    int totalActiveMalClassA = 0;
    int totalActiveMalClassB = 0;
    int totalActiveMalClassC = 0;
    int totalActiveMalClassD = 0;
    int totalNominalMal = 0;

    int totalActiveBnPu = 0;
    int totalActiveBnClassA = 0;
    int totalActiveBnClassB = 0;
    int totalActiveBnClassC = 0;
    int totalActiveBnClassD = 0;

    int totalNewMember = 0;
    int totalKdpu = 0;

    // Group by shafUuid to get unique shafs and their totals
    final shafMap = <String, ShafEntity>{};

    for (final monev in monevList) {
      totalActiveMalPu += monev.activeMalPu;
      totalActiveMalClassA += monev.activeMalClassA;
      totalActiveMalClassB += monev.activeMalClassB;
      totalActiveMalClassC += monev.activeMalClassC;
      totalActiveMalClassD += monev.activeMalClassD;
      totalNominalMal += monev.nominalMal;

      totalActiveBnPu += monev.activeBnPu;
      totalActiveBnClassA += monev.activeBnClassA;
      totalActiveBnClassB += monev.activeBnClassB;
      totalActiveBnClassC += monev.activeBnClassC;
      totalActiveBnClassD += monev.activeBnClassD;

      totalNewMember += monev.totalNewMember;
      totalKdpu += monev.totalKdpu;

      // Store shaf data by uuid
      if (monev.shafUuid != null && monev.shaf != null) {
        shafMap[monev.shafUuid!] = monev.shaf!;
      }
    }

    // Calculate total PU and class totals from unique shafs
    int totalPu = 0;
    int totalClassA = 0;
    int totalClassB = 0;
    int totalClassC = 0;
    int totalClassD = 0;

    for (final shaf in shafMap.values) {
      totalPu += shaf.totalPu;
      totalClassA += shaf.totalClassA;
      totalClassB += shaf.totalClassB;
      totalClassC += shaf.totalClassC;
      totalClassD += shaf.totalClassD;
    }

    // Get the latest week number from the data (safely handle single item)
    final latestWeekNumber = monevList.length == 1
        ? monevList.first.weekNumber
        : monevList.map((m) => m.weekNumber).reduce((a, b) => a > b ? a : b);

    // Get bengkel name from shaf data in the response
    String? bengkelName;
    if (selectedBengkelUuid.value != null && shafMap.isNotEmpty) {
      // Get the first shaf's bengkel name from the response
      bengkelName = shafMap.values.first.bengkelName;
    }

    return MonevSummary(
      bulanHijriah: firstMonev.bulanHijriah,
      tahunHijriah: firstMonev.tahunHijriah,
      latestWeekNumber: latestWeekNumber,
      shafUuid: selectedBengkelUuid.value,
      shafName: bengkelName,
      activeMalPu: totalActiveMalPu,
      activeMalClassA: totalActiveMalClassA,
      activeMalClassB: totalActiveMalClassB,
      activeMalClassC: totalActiveMalClassC,
      activeMalClassD: totalActiveMalClassD,
      nominalMal: totalNominalMal,
      activeBnPu: totalActiveBnPu,
      activeBnClassA: totalActiveBnClassA,
      activeBnClassB: totalActiveBnClassB,
      activeBnClassC: totalActiveBnClassC,
      activeBnClassD: totalActiveBnClassD,
      totalNewMember: totalNewMember,
      totalKdpu: totalKdpu,
      totalPu: totalPu,
      totalClassA: totalClassA,
      totalClassB: totalClassB,
      totalClassC: totalClassC,
      totalClassD: totalClassD,
      narrationMal: firstMonev.narrationMal,
      narrationBn: firstMonev.narrationBn,
      narrationDkw: firstMonev.narrationDkw,
    );
  }

  Future<void> loadAll() async {
    loading.value = true;
    connectionError.value = null;
    currentPage.value = 1;
    try {
      final response = await _apiRepo.getAll(
        shafUuid: selectedBengkelUuid.value,
        bulanHijriah: selectedBulanHijriah.value?.name,
        tahunHijriah: selectedTahunHijriah.value,
        weekNumber: selectedPekan.value,
        page: currentPage.value,
        limit: pageLimit.value,
      );
      items.value = response['data'] as List<Monev>;
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
      final response = await _apiRepo.getAll(
        shafUuid: selectedBengkelUuid.value,
        bulanHijriah: selectedBulanHijriah.value?.name,
        tahunHijriah: selectedTahunHijriah.value,
        weekNumber: selectedPekan.value,
        page: currentPage.value,
        limit: pageLimit.value,
      );
      final newItems = response['data'] as List<Monev>;
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

  Future<void> loadBengkelList() async {
    loadingBengkel.value = true;
    try {
      final shafApiRepo = Get.isRegistered<ShafApiRepository>()
          ? Get.find<ShafApiRepository>()
          : Get.put(ShafApiRepository(), permanent: true);
      final response = await shafApiRepo.getAll();
      bengkelList.value = response['data'] as List<ShafEntity>;
    } catch (e) {
      bengkelList.value = [];
    } finally {
      loadingBengkel.value = false;
    }
  }

  Future<void> loadAvailableMonthYears() async {
    try {
      final maps = await _localRepo.getAvailableMonthYears();
      availableMonthYears.value = maps;

      // Set default to the first (most recent) month/year
      if (maps.isNotEmpty) {
        final first = maps.first;
        final month = HijriahMonthX.fromDb(first['bulan_hijriah'] as String);
        final year = first['tahun_hijriah'] as int;

        // Set both old and new filter variables
        selectedMonth.value = month;
        selectedYear.value = year;
        selectedBulanHijriah.value = month;
        selectedTahunHijriah.value = year;

        await loadAvailableShafs();
        await loadSummary();
        await loadSummaryWithFilters();
      }
    } catch (_) {
      // Silently handle error - no data available yet
    }
  }

  Future<void> loadAvailableShafs() async {
    if (selectedMonth.value == null || selectedYear.value == null) return;

    try {
      final shafUuids = await _localRepo.getAvailableShafsByMonthYear(
        selectedMonth.value!,
        selectedYear.value!,
      );

      // Get shaf details from ShafApiRepository
      final shafApiRepo = Get.isRegistered<ShafApiRepository>()
          ? Get.find<ShafApiRepository>()
          : Get.put(ShafApiRepository(), permanent: true);

      final shafs = <ShafEntity>[];
      for (final uuid in shafUuids) {
        final shaf = await shafApiRepo.findById(uuid);
        if (shaf != null) {
          shafs.add(shaf);
        }
      }

      availableShafs.value = shafs;
      selectedShafUuid.value = null; // Reset to "all shafs"
    } catch (_) {
      // Silently handle error
      availableShafs.value = [];
      selectedShafUuid.value = null;
    }
  }

  Future<void> loadSummary() async {
    if (selectedMonth.value == null || selectedYear.value == null) return;

    summaryLoading.value = true;
    try {
      if (selectedShafUuid.value != null) {
        // Load summary for specific shaf
        currentSummary.value = await _localRepo.getSummaryByMonthYearAndShaf(
          selectedMonth.value!,
          selectedYear.value!,
          selectedShafUuid.value!,
        );
      } else {
        // Load summary for all shafs
        currentSummary.value = await _localRepo.getSummaryByMonthYear(
          selectedMonth.value!,
          selectedYear.value!,
        );
      }
    } finally {
      summaryLoading.value = false;
    }
  }

  Future<void> selectMonthYear(HijriahMonth month, int year) async {
    selectedMonth.value = month;
    selectedYear.value = year;
    await loadAvailableShafs();
    await loadSummary();
  }

  Future<void> selectShaf(String? shafUuid) async {
    selectedShafUuid.value = shafUuid;
    await loadSummary();
  }

  Future<void> create({
    required String? shafUuid,
    required HijriahMonth bulanHijriah,
    required int tahunHijriah,
    required int weekNumber,
    required int activeMalPu,
    required int activeMalClassA,
    required int activeMalClassB,
    required int activeMalClassC,
    required int activeMalClassD,
    required int nominalMal,
    required int activeBnPu,
    required int activeBnClassA,
    required int activeBnClassB,
    required int activeBnClassC,
    required int activeBnClassD,
    required int totalNewMember,
    required int totalKdpu,
    String? narrationMal,
    String? narrationBn,
    String? narrationDkw,
  }) async {
    final now = DateTime.now().toIso8601String();
    final e = Monev(
      uuid: const Uuid().v4(),
      shafUuid: shafUuid,
      bulanHijriah: bulanHijriah,
      tahunHijriah: tahunHijriah,
      weekNumber: weekNumber,
      activeMalPu: activeMalPu,
      activeMalClassA: activeMalClassA,
      activeMalClassB: activeMalClassB,
      activeMalClassC: activeMalClassC,
      activeMalClassD: activeMalClassD,
      nominalMal: nominalMal,
      activeBnPu: activeBnPu,
      activeBnClassA: activeBnClassA,
      activeBnClassB: activeBnClassB,
      activeBnClassC: activeBnClassC,
      activeBnClassD: activeBnClassD,
      totalNewMember: totalNewMember,
      totalKdpu: totalKdpu,
      narrationMal: narrationMal,
      narrationBn: narrationBn,
      narrationDkw: narrationDkw,
      createdAt: now,
      updatedAt: now,
    );
    await _apiRepo.create(e);
    await loadAll();
    await loadAvailableMonthYears();
  }

  Future<void> updateItem(Monev e) async {
    final updated = e.copyWith(updatedAt: DateTime.now().toIso8601String());
    await _apiRepo.update(updated);
    await loadAll();
    await loadAvailableMonthYears();
  }

  Future<void> deleteItem(String uuid) async {
    await _apiRepo.delete(uuid);
    await loadAll();
    await loadAvailableMonthYears();
  }
}
