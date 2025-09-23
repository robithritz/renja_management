import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'modules/renja/renja_list_page.dart';
import 'data/repositories/renja_repository.dart';
import 'modules/renja/renja_controller.dart';

import 'shared/controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize locale data for intl (e.g., id_ID month names, currency)
  await initializeDateFormatting('id_ID', null);
  // Put dependencies
  Get.put<SettingsController>(SettingsController(), permanent: true);

  Get.put<RenjaRepository>(RenjaRepository(), permanent: true);
  Get.put<RenjaController>(RenjaController(Get.find()), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Renja Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final settings = Get.find<SettingsController>();
        return Obx(
          () => MediaQuery(
            data: mq.copyWith(
              textScaler: TextScaler.linear(settings.textScale.value),
            ),
            child: child!,
          ),
        );
      },
      home: const RenjaListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
