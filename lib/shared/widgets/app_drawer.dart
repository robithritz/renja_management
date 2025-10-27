import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/renja/renja_list_page.dart';
import '../../modules/shaf/shaf_list_page.dart';
import '../../modules/monev/monev_list_page.dart';

enum DrawerItem { renja, shaf, monev }

class AppDrawer extends StatelessWidget {
  final DrawerItem selectedItem;

  const AppDrawer({
    super.key,
    required this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
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
            selected: selectedItem == DrawerItem.renja,
            selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Color(0xFF135193)),
            title: const Text('Bengkel'),
            onTap: () => Get.offAll(() => const ShafListPage()),
            selected: selectedItem == DrawerItem.shaf,
            selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
          ),
          ListTile(
            leading: const Icon(Icons.assessment, color: Color(0xFF135193)),
            title: const Text('Monev'),
            onTap: () => Get.offAll(() => const MonevListPage()),
            selected: selectedItem == DrawerItem.monev,
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
}

