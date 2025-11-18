import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/renja/renja_list_page.dart';
import '../../modules/shaf/shaf_list_page.dart';
import '../../modules/monev/monev_list_page.dart';
import '../controllers/auth_controller.dart';

enum DrawerItem { renja, shaf, monev }

class AppDrawer extends StatelessWidget {
  final DrawerItem selectedItem;

  const AppDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const _DrawerHeader(),
          _DrawerRenjaItem(isSelected: selectedItem == DrawerItem.renja),
          _DrawerShafItem(isSelected: selectedItem == DrawerItem.shaf),
          _DrawerMonevItem(isSelected: selectedItem == DrawerItem.monev),
          const Divider(height: 24),
          const _DrawerSettingsItem(),
          const Divider(height: 24),
          const _DrawerLogoutItem(),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
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
    );
  }
}

class _DrawerRenjaItem extends StatelessWidget {
  final bool isSelected;
  const _DrawerRenjaItem({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.list, color: Color(0xFF135193)),
      title: const Text('Renja'),
      onTap: () => Get.offAll(() => const RenjaListPage()),
      selected: isSelected,
      selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
    );
  }
}

class _DrawerShafItem extends StatelessWidget {
  final bool isSelected;
  const _DrawerShafItem({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group, color: Color(0xFF135193)),
      title: const Text('Bengkel'),
      onTap: () => Get.offAll(() => const ShafListPage()),
      selected: isSelected,
      selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
    );
  }
}

class _DrawerMonevItem extends StatelessWidget {
  final bool isSelected;
  const _DrawerMonevItem({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.assessment, color: Color(0xFF135193)),
      title: const Text('Monev'),
      onTap: () => Get.offAll(() => const MonevListPage()),
      selected: isSelected,
      selectedTileColor: const Color(0xFF135193).withValues(alpha: 0.1),
    );
  }
}

class _DrawerSettingsItem extends StatelessWidget {
  const _DrawerSettingsItem();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings, color: Color(0xFF8D949B)),
      title: const Text('Settings'),
      onTap: () => Get.back(),
    );
  }
}

class _DrawerLogoutItem extends StatelessWidget {
  const _DrawerLogoutItem();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Logout'),
      onTap: () async {
        Get.back(); // Close drawer

        // Show confirmation dialog
        final confirm = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          final authController = Get.find<AuthController>();
          await authController.logout();
          Get.offAllNamed('/login');
        }
      },
    );
  }
}
