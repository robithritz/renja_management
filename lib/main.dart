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
      theme: _buildCorporateTheme(),
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

  static ThemeData _buildCorporateTheme() {
    // Primary Colors (Pantone)
    const Color darkNavy = Color(0xFF041E42); // Pantone 282C
    const Color corporateBlue = Color(0xFF135193); // Pantone 4152C
    const Color limeGreen = Color(0xFF93DA49); // Pantone 2285C

    // Secondary Colors (Pantone)
    const Color dustyBlue = Color(0xFF5F8FB4); // Pantone 7454C
    const Color coolGray = Color(0xFF8D949B); // Pantone 6211C

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: corporateBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE8F1F8),
        onPrimaryContainer: darkNavy,
        secondary: dustyBlue,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFE8EEF5),
        onSecondaryContainer: darkNavy,
        tertiary: limeGreen,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFF0F8E8),
        onTertiaryContainer: const Color(0xFF2D5A1A),
        error: const Color(0xFFB3261E),
        onError: Colors.white,
        errorContainer: const Color(0xFFF9DEDC),
        onErrorContainer: const Color(0xFF410E0B),
        surface: Colors.white,
        onSurface: darkNavy,
        surfaceContainerHighest: const Color(0xFFE8EEF5),
        onSurfaceVariant: coolGray,
        outline: coolGray,
        outlineVariant: const Color(0xFFC7CDD5),
        shadow: Colors.black.withValues(alpha: 0.12),
        scrim: Colors.black.withValues(alpha: 0.12),
        inverseSurface: darkNavy,
        onInverseSurface: Colors.white,
        inversePrimary: limeGreen,
      ),
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: corporateBlue.withValues(alpha: 0.05),
      ),
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corporateBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: corporateBlue,
          side: const BorderSide(color: corporateBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: corporateBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corporateBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
        ),
        labelStyle: const TextStyle(
          color: coolGray,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: coolGray.withValues(alpha: 0.6)),
      ),
      // Dropdown Theme
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFBFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE8EEF5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: corporateBlue, width: 2),
          ),
        ),
      ),
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkNavy,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkNavy,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkNavy,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkNavy,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkNavy,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkNavy,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkNavy,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: coolGray,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkNavy,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkNavy,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: coolGray,
        ),
      ),
      // Icon Theme
      iconTheme: const IconThemeData(color: corporateBlue, size: 24),
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: corporateBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE8EEF5),
        selectedColor: corporateBlue,
        labelStyle: const TextStyle(
          color: darkNavy,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EEF5),
        thickness: 1,
        space: 16,
      ),
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFFFAFBFC),
    );
  }
}
