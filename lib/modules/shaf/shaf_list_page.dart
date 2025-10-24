import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'shaf_controller.dart';
import '../../data/models/shaf_entity.dart';
import 'shaf_form_page.dart';
import '../renja/renja_list_page.dart';
import '../monev/monev_list_page.dart';

class ShafListPage extends StatelessWidget {
  const ShafListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShafController>()) {
      Get.put(ShafController(Get.find()), permanent: true);
    }
    final c = Get.find<ShafController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Shaf')),
      drawer: _buildAppDrawer(),
      body: Obx(() {
        if (c.loading.value)
          return const Center(child: CircularProgressIndicator());
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
            child: const Center(child: Text('Belum ada data Shaf')),
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
                      await Get.to(() => ShafFormPage(initial: e));
                      await c.loadAll();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            e.asiaName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          // Info row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  icon: Icons.business,
                                  label: e.rakitName,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoChip(
                                  icon: Icons.people,
                                  label: 'PU: ${e.totalPu}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Class breakdown
                          Row(
                            children: [
                              Expanded(
                                child: _buildClassCard('A', e.totalClassA),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildClassCard('B', e.totalClassB),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildClassCard('C', e.totalClassC),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildClassCard('D', e.totalClassD),
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
                                  await Get.to(() => ShafFormPage(initial: e));
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
                                      title: const Text('Hapus Shaf?'),
                                      content: Text(e.asiaName),
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
          await Get.to(() => const ShafFormPage());
          await c.loadAll();
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildInfoChip({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF135193).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF135193).withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF135193)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF135193),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildClassCard(String className, int count) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF93DA49).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF93DA49).withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        Text(
          'Kelas $className',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D5A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF93DA49),
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
          onTap: () => Get.back(),
          selected: true,
          selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
        ),
        ListTile(
          leading: const Icon(Icons.assessment, color: Color(0xFF135193)),
          title: const Text('Monev'),
          onTap: () => Get.offAll(() => const MonevListPage()),
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
