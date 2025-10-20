import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/monev_repository.dart';
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
    if (!Get.isRegistered<MonevController>()) {
      Get.put(MonevController(Get.find()), permanent: true);
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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Renja'),
              onTap: () => Get.offAll(() => const RenjaListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Shaf'),
              onTap: () => Get.offAll(() => const ShafListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Monev'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.items.isEmpty) {
          return const Center(child: Text('Belum ada data Monev'));
        }
        return ListView.separated(
          itemCount: c.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = c.items[i];
            return ListTile(
              title: Text(
                'Pekan ${e.weekNumber} - ${e.bulanHijriah.asString} ${e.tahunHijriah}',
              ),
              subtitle: Text(
                'BN PU: ${e.activeBnPu} | MAL PU: ${e.activeMalPu} | New: ${e.totalNewMember}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Get.to(() => MonevFormPage(initial: e));
                      await c.loadAll();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
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
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
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
            );
          },
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
