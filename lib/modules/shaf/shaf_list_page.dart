import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/shaf_repository.dart';
import 'shaf_controller.dart';
import '../../data/models/shaf_entity.dart';
import 'shaf_form_page.dart';
import '../renja/renja_list_page.dart';
import '../monev/monev_list_page.dart';

class ShafListPage extends StatelessWidget {
  const ShafListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShafRepository>()) {
      Get.put(ShafRepository(), permanent: true);
    }
    if (!Get.isRegistered<ShafController>()) {
      Get.put(ShafController(Get.find()), permanent: true);
    }
    final c = Get.find<ShafController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Shaf')),
      drawer: _AppDrawer(),
      body: Obx(() {
        if (c.loading.value)
          return const Center(child: CircularProgressIndicator());
        if (c.items.isEmpty) {
          return const Center(child: Text('Belum ada data Shaf'));
        }
        return ListView.separated(
          itemCount: c.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = c.items[i];
            return ListTile(
              title: Text('${e.asiaName}'),
              subtitle: Text('Rakit: ${e.rakitName} | PU: ${e.totalPu}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Get.to(() => ShafFormPage(initial: e));
                      await c.loadAll();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus Shaf?'),
                          content: Text(e.asiaName),
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
          await Get.to(() => const ShafFormPage());
          await c.loadAll();
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Monev'),
            onTap: () => Get.offAll(() => const MonevListPage()),
          ),
        ],
      ),
    );
  }
}
