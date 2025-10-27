import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/monev_repository.dart';
import '../../data/repositories/monev_api_repository.dart';
import 'monev_controller.dart';
import '../../shared/enums/hijriah_month.dart';
import '../../shared/widgets/app_drawer.dart';
import 'monev_form_page.dart';
import 'monev_summary_page.dart';

class MonevListPage extends StatelessWidget {
  const MonevListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MonevRepository>()) {
      Get.put(MonevRepository(), permanent: true);
    }
    if (!Get.isRegistered<MonevApiRepository>()) {
      Get.put(MonevApiRepository(), permanent: true);
    }
    if (!Get.isRegistered<MonevController>()) {
      Get.put(
        MonevController(
          Get.find<MonevApiRepository>(),
          Get.find<MonevRepository>(),
        ),
        permanent: true,
      );
    }
    final c = Get.find<MonevController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monev'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ringkasan',
            onPressed: () => Get.to(() => const MonevSummaryPage()),
          ),
        ],
      ),
      drawer: const AppDrawer(selectedItem: DrawerItem.monev),
      body: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              // Show connection error
              if (c.connectionError.value != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Connection Error',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          c.connectionError.value!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () => c.loadAll(),
                      ),
                    ],
                  ),
                );
              }
              if (c.items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => c.loadAll(),
                  child: const Center(child: Text('Belum ada data Monev')),
                );
              }
              return RefreshIndicator(
                onRefresh: () => c.loadAll(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: c.items.length + (c.hasMorePages ? 1 : 0),
                  itemBuilder: (context, i) {
                    // Loading indicator at the end
                    if (i == c.items.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: c.loadingMore.value
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: () => c.loadMore(),
                                  child: const Text('Load More'),
                                ),
                        ),
                      );
                    }

                    final e = c.items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () async {
                            await Get.to(() => MonevFormPage(initial: e));
                            await c.loadAll();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pekan ${e.weekNumber}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${e.bulanHijriah.asString} ${e.tahunHijriah}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (e.shaf?.bengkelName != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF135193,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF135193,
                                            ).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          e.shaf!.bengkelName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF135193),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Stats Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        label: 'BN PU',
                                        value: '${e.activeBnPu}',
                                        icon: Icons.people,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        label: 'MAL PU',
                                        value: '${e.activeMalPu}',
                                        icon: Icons.group,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        label: 'New',
                                        value: '${e.totalNewMember}',
                                        icon: Icons.person_add,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Action buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                      onPressed: () async {
                                        await Get.to(
                                          () => MonevFormPage(initial: e),
                                        );
                                        await c.loadAll();
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Delete'),
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Hapus Monev?'),
                                            content: Text(
                                              'Pekan ${e.weekNumber} - ${e.bulanHijriah.asString} ${e.tahunHijriah}',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Batal'),
                                              ),
                                              FilledButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          await c.deleteItem(e.uuid);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const MonevFormPage());
          await c.loadAll();
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MonevController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.filter_list),
          label: const Text('Filter'),
          onPressed: () => _showFilterDialog(context, c),
        ),
      );
    }

    return Obx(() {
      final years = [1446, 1447, 1448, 1449, 1450].toList()..sort();
      final months = HijriahMonth.values.toList()
        ..sort((a, b) => a.asString.compareTo(b.asString));
      const pekanNumbers = [1, 2, 3, 4];

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Filter:'),
            _BengkelFilterDropdown(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahun Hijriah',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: c.selectedTahunHijriah.value,
                    hint: const Text('Tahun'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...years.map(
                        (y) =>
                            DropdownMenuItem<int?>(value: y, child: Text('$y')),
                      ),
                    ],
                    onChanged: (v) => c.selectedTahunHijriah.value = v,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulan Hijriah',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButton<HijriahMonth?>(
                    isExpanded: true,
                    value: c.selectedBulanHijriah.value,
                    hint: const Text('Bulan'),
                    items: [
                      const DropdownMenuItem<HijriahMonth?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...months.map(
                        (m) => DropdownMenuItem<HijriahMonth?>(
                          value: m,
                          child: Text(m.asString),
                        ),
                      ),
                    ],
                    onChanged: (v) => c.selectedBulanHijriah.value = v,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pekan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: c.selectedPekan.value,
                    hint: const Text('Pekan'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...pekanNumbers.map(
                        (p) =>
                            DropdownMenuItem<int?>(value: p, child: Text('$p')),
                      ),
                    ],
                    onChanged: (v) => c.selectedPekan.value = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showFilterDialog(BuildContext context, MonevController c) {
    showDialog(
      context: context,
      builder: (_) => _FilterDialogContent(controller: c),
    );
  }
}

class _BengkelFilterDropdown extends StatelessWidget {
  const _BengkelFilterDropdown();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MonevController>();
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bengkel',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(
            width: 180,
            child: c.loadingBengkel.value
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String?>(
                    isExpanded: true,
                    value: c.selectedBengkelUuid.value,
                    hint: const Text('Bengkel'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...c.bengkelList.map(
                        (b) => DropdownMenuItem<String?>(
                          value: b.uuid,
                          child: Text(b.bengkelName),
                        ),
                      ),
                    ],
                    onChanged: (v) => c.selectedBengkelUuid.value = v,
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialogContent extends StatelessWidget {
  final MonevController controller;

  const _FilterDialogContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final years = controller.items.map((e) => e.tahunHijriah).toSet().toList()
        ..sort();
      final months = HijriahMonth.values.toList()
        ..sort((a, b) => a.asString.compareTo(b.asString));
      const pekanNumbers = [1, 2, 3, 4];

      return AlertDialog(
        title: const Text('Filter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bengkel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              controller.loadingBengkel.value
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButton<String?>(
                      isExpanded: true,
                      value: controller.selectedBengkelUuid.value,
                      hint: const Text('Bengkel'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...controller.bengkelList.map(
                          (b) => DropdownMenuItem<String?>(
                            value: b.uuid,
                            child: Text(b.bengkelName),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          controller.selectedBengkelUuid.value = v,
                    ),
              const SizedBox(height: 16),
              Text(
                'Tahun Hijriah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<int?>(
                isExpanded: true,
                value: controller.selectedTahunHijriah.value,
                hint: const Text('Tahun Hijriah'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All')),
                  ...years.map(
                    (y) => DropdownMenuItem<int?>(value: y, child: Text('$y')),
                  ),
                ],
                onChanged: (v) => controller.selectedTahunHijriah.value = v,
              ),
              const SizedBox(height: 16),
              Text(
                'Bulan Hijriah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<HijriahMonth?>(
                isExpanded: true,
                value: controller.selectedBulanHijriah.value,
                hint: const Text('Bulan Hijriah'),
                items: [
                  const DropdownMenuItem<HijriahMonth?>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...months.map(
                    (m) => DropdownMenuItem<HijriahMonth?>(
                      value: m,
                      child: Text(m.asString),
                    ),
                  ),
                ],
                onChanged: (v) => controller.selectedBulanHijriah.value = v,
              ),
              const SizedBox(height: 16),
              Text(
                'Pekan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<int?>(
                isExpanded: true,
                value: controller.selectedPekan.value,
                hint: const Text('Pekan'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All')),
                  ...pekanNumbers.map(
                    (p) => DropdownMenuItem<int?>(value: p, child: Text('$p')),
                  ),
                ],
                onChanged: (v) => controller.selectedPekan.value = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      );
    });
  }
}

Widget _buildStatCard({
  required String label,
  required String value,
  required IconData icon,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF135193).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF135193).withValues(alpha: 0.2)),
    ),
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFF135193), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF135193),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8D949B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
