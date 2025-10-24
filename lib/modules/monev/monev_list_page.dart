import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/monev_repository.dart';
import '../../data/repositories/monev_api_repository.dart';
import 'monev_controller.dart';
import '../../shared/enums/hijriah_month.dart';

import '../renja/renja_list_page.dart';
import '../shaf/shaf_list_page.dart';
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
      drawer: _buildAppDrawer(),
      body: Obx(() {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (e.shafName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF135193,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF135193,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    e.shafName!,
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
                                  await Get.to(() => MonevFormPage(initial: e));
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
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
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

Widget _buildAppDrawer() {
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF041E42)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.dashboard, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              const Text(
                'Renja Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Management System',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.list, color: Color(0xFF135193)),
          title: const Text('Renja'),
          onTap: () => Get.offAll(() => const RenjaListPage()),
        ),
        ListTile(
          leading: const Icon(Icons.group, color: Color(0xFF135193)),
          title: const Text('Shaf'),
          onTap: () => Get.offAll(() => const ShafListPage()),
        ),
        ListTile(
          leading: const Icon(Icons.assessment, color: Color(0xFF135193)),
          title: const Text('Monev'),
          onTap: () => Get.back(),
          selected: true,
          selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
        ),
        const Divider(height: 24),
        ListTile(
          leading: const Icon(Icons.settings, color: Color(0xFF8D949B)),
          title: const Text('Settings'),
          onTap: () => Get.back(),
        ),
      ],
    ),
  );
}
