import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';
import 'renja_controller.dart';
import 'renja_form_page.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:file_selector/file_selector.dart';
import '../../data/models/renja.dart';
import 'dart:typed_data';

import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';

import '../../shared/controllers/settings_controller.dart';
import '../../shared/widgets/app_drawer.dart';

// ============================================================================
// STATIC CONST DECORATIONS - Phase 3 Optimization
// These are defined once at compile time to eliminate object allocations
// during scrolling. Each decoration is created once and reused.
// ============================================================================

// Status Badge Decorations (Tergelar - Green)
const Color _statusTergelarBgColor = Color(0xFF93DA49);
const Color _statusTergelarTextColor = Color(0xFF2D5A1A);

// Status Badge Decorations (Tidak Tergelar - Red)
const Color _statusTidakTergelarBgColor = Colors.red;
const Color _statusTidakTergelarTextColor = Colors.red;

// Info Chip Decorations
const Color _infoBgColor = Color(0xFF135193);
const Color _infoTextColor = Color(0xFF135193);

// Border Radius Constants
const double _borderRadiusSmall = 8.0;
const double _borderRadiusMedium = 12.0;

// Padding Constants
const EdgeInsets _paddingSmall = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 6,
);
const EdgeInsets _paddingTiny = EdgeInsets.symmetric(
  horizontal: 8,
  vertical: 4,
);

// ============================================================================
// STATIC CONST DECORATION OBJECTS
// ============================================================================

// Status Badge - Tergelar (Green background with border)
const BoxDecoration _statusTergelarDecoration = BoxDecoration(
  color: Color(0xFF93DA49), // Will be overridden with alpha in build
  borderRadius: BorderRadius.all(Radius.circular(_borderRadiusSmall)),
);

// Status Badge - Tidak Tergelar (Red background with border)
const BoxDecoration _statusTidakTergelarDecoration = BoxDecoration(
  color: Colors.red, // Will be overridden with alpha in build
  borderRadius: BorderRadius.all(Radius.circular(_borderRadiusSmall)),
);

// Info Chip Decoration
const BoxDecoration _infoChipDecoration = BoxDecoration(
  color: Color(0xFF135193), // Will be overridden with alpha in build
  borderRadius: BorderRadius.all(Radius.circular(_borderRadiusSmall)),
);

// Border Radius for decorations
const BorderRadius _borderRadiusSmallRadius = BorderRadius.all(
  Radius.circular(_borderRadiusSmall),
);

class RenjaListPage extends StatelessWidget {
  const RenjaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renja Management'),
        actions: [
          IconButton(
            tooltip: 'Export to Excel',
            icon: const Icon(Icons.download),
            onPressed: () async => _exportExcel(
              items: c.filteredItems,
              bulan: c.selectedBulanHijriah.value,
              tahun: c.selectedTahunHijriah.value,
              instansiFilter: c.selectedInstansi.value,
            ),
          ),
          IconButton(
            tooltip: 'A-',
            icon: const Icon(Icons.text_decrease),
            onPressed: () => Get.find<SettingsController>().dec(),
          ),
          IconButton(
            tooltip: 'A+',
            icon: const Icon(Icons.text_increase),
            onPressed: () => Get.find<SettingsController>().inc(),
          ),
          Obx(() {
            final isCal = c.calendarMode.value;
            return IconButton(
              tooltip: isCal ? 'Show list' : 'Show calendar',
              icon: Icon(isCal ? Icons.view_list : Icons.calendar_month),
              onPressed: () => c.calendarMode.toggle(),
            );
          }),
        ],
      ),
      drawer: const AppDrawer(selectedItem: DrawerItem.renja),
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
        if (c.calendarMode.value) {
          return Column(
            children: [
              _FilterBar(),
              Expanded(child: _CalendarView()),
            ],
          );
        }
        // List mode with filter by instansi
        final filtered = c.filteredItems;
        return Column(
          children: [
            _FilterBar(),
            Expanded(
              child: filtered.isEmpty
                  ? RefreshIndicator(
                      onRefresh: () => c.loadAll(),
                      child: const Center(
                        child: Text('No data. Tap + to add.'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        c.currentPage.value = 1;
                        return c.loadAll();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length + (c.hasMorePages ? 1 : 0),
                        itemBuilder: (context, i) {
                          // Loading indicator at the end
                          if (i == filtered.length) {
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

                          final r = filtered[i];
                          return _RenjaListItem(
                            renja: r,
                            onEdit: () async {
                              await Get.to(() => RenjaFormPage(existing: r));
                              await c.loadAll();
                            },
                            onDelete: () async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text('Delete?'),
                                  content: Text('Delete "${r.kegiatanDesc}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await c.deleteItem(r.uuid);
                              }
                            },
                            onWarning: () async {
                              await _showTergelarDialog(context, r);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const RenjaFormPage());
          await c.loadAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Obx(() {
      final month = c.currentMonth.value;
      final first = DateTime(month.year, month.month, 1);
      final last = DateTime(month.year, month.month + 1, 0);
      final leading = first.weekday - 1; // Monday=0
      final days = last.day;
      final headerFmt = DateFormat('MMMM yyyy', 'id_ID');
      final isoFmt = DateFormat('yyyy-MM-dd');

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final m = c.currentMonth.value;
                    c.currentMonth.value = DateTime(m.year, m.month - 1);
                  },
                ),
                Text(
                  headerFmt.format(month),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final m = c.currentMonth.value;
                    c.currentMonth.value = DateTime(m.year, m.month + 1);
                  },
                ),
              ],
            ),
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(child: Center(child: Text('Mon'))),
                  Expanded(child: Center(child: Text('Tue'))),
                  Expanded(child: Center(child: Text('Wed'))),
                  Expanded(child: Center(child: Text('Thu'))),
                  Expanded(child: Center(child: Text('Fri'))),
                  Expanded(child: Center(child: Text('Sat'))),
                  Expanded(child: Center(child: Text('Sun'))),
                ],
              ),
            ),
          Expanded(
            child: isMobile
                ? _buildMobileCalendar(context, c, month, days, isoFmt, leading)
                : _buildDesktopCalendar(
                    context,
                    c,
                    month,
                    days,
                    isoFmt,
                    leading,
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildDesktopCalendar(
    BuildContext context,
    RenjaController c,
    DateTime month,
    int days,
    DateFormat isoFmt,
    int leading,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 7;
        final total = leading + days;
        final rows = (total / columns).ceil().clamp(1, 6);
        final cellWidth = constraints.maxWidth / columns;
        final cellHeight = constraints.maxHeight / rows;
        final aspect = cellWidth / cellHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspect,
          ),
          itemCount: leading + days,
          itemBuilder: (context, index) {
            if (index < leading) return const SizedBox.shrink();
            final day = index - leading + 1;
            return _buildCalendarCell(context, c, month, day, isoFmt);
          },
        );
      },
    );
  }

  Widget _buildMobileCalendar(
    BuildContext context,
    RenjaController c,
    DateTime month,
    int days,
    DateFormat isoFmt,
    int leading,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: (days / 2).ceil(),
      itemBuilder: (context, rowIndex) {
        final day1 = rowIndex * 2 + 1;
        final day2 = day1 + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 120,
                  child: _buildCalendarCell(context, c, month, day1, isoFmt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: day2 <= days
                    ? SizedBox(
                        height: 120,
                        child: _buildCalendarCell(
                          context,
                          c,
                          month,
                          day2,
                          isoFmt,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarCell(
    BuildContext context,
    RenjaController c,
    DateTime month,
    int day,
    DateFormat isoFmt,
  ) {
    final date = DateTime(month.year, month.month, day);
    final iso = isoFmt.format(date);
    final items = c.getItemsByDate(iso);
    final has = items.isNotEmpty;

    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          if (items.isEmpty) return;
          showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = items[i];
                  return ListTile(
                    title: Text(r.kegiatanDesc),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.time} • ${r.instansi.asString}'),
                        Text(
                          'Hijriah: ${r.bulanHijriah.asString} ${r.tahunHijriah}',
                        ),
                        if (r.sasaran.isNotEmpty) Text('Sasaran: ${r.sasaran}'),
                        if (r.tujuan.isNotEmpty) Text('Tujuan: ${r.tujuan}'),
                        if (r.target.isNotEmpty) Text('Target: ${r.target}'),
                        if (r.pic.isNotEmpty) Text('PIC: ${r.pic}'),
                        if (r.titikDesc.isNotEmpty)
                          Text('Titik: ${r.titikDesc}'),
                        if (r.isTergelar == false)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                (() {
                                  final rs =
                                      r.reasonTidakTergelar?.trim() ?? '';
                                  return rs.isNotEmpty
                                      ? 'Tidak tergelar — $rs'
                                      : 'Tidak tergelar';
                                })(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: has ? Colors.teal.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '$day',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: has
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...items
                                .take(2)
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      e.kegiatanDesc,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _instansiColor(e.instansi),
                                      ),
                                    ),
                                  ),
                                ),
                            if (items.length > 2)
                              const Text(
                                '...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (has)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _instansiColor(Instansi i) {
  switch (i) {
    case Instansi.EKL:
      return Colors.teal;
    case Instansi.DAKWAH:
      return Colors.deepPurple;
    case Instansi.IKK:
      return Colors.orange;
    case Instansi.TRB:
      return Colors.blue;
    case Instansi.UP:
      return Colors.pink;
  }
}

// Extracted List Item Widget with const constructor for memoization
class _RenjaListItem extends StatelessWidget {
  final Renja renja;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onWarning;

  const _RenjaListItem({
    required this.renja,
    required this.onEdit,
    required this.onDelete,
    this.onWarning,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              renja.kegiatanDesc,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${renja.dayName} ${renja.formattedDate} • ${renja.time}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (renja.isTergelar != null) _StatusBadge(renja: renja),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.business,
                          label: renja.instansi.asString,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.calendar_today,
                          label:
                              '${renja.bulanHijriah.asString} ${renja.tahunHijriah}',
                        ),
                      ),
                    ],
                  ),
                  if (renja.sasaran.isNotEmpty || renja.tujuan.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Sasaran: ${renja.sasaran}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (renja.isDatePassed && renja.isTergelar == null)
                        IconButton(
                          icon: const Icon(
                            Icons.warning_amber,
                            color: Color(0xFFFFA500),
                            size: 24,
                          ),
                          onPressed: onWarning,
                          tooltip: 'Past date - not completed',
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final Renja renja;

  const _StatusBadge({required this.renja});

  @override
  Widget build(BuildContext context) {
    final isComplete = renja.isTergelar == true;

    // Use pre-computed colors with alpha values
    final bgColor = isComplete
        ? const Color(0xFF93DA49).withValues(alpha: 0.15)
        : Colors.red.withValues(alpha: 0.15);
    final borderColor = isComplete
        ? const Color(0xFF93DA49).withValues(alpha: 0.5)
        : Colors.red.withValues(alpha: 0.5);
    final textColor = isComplete
        ? const Color(0xFF2D5A1A)
        : Colors.red.shade800;

    return Container(
      padding: _paddingSmall,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: _borderRadiusSmallRadius,
        border: Border.all(color: borderColor),
      ),
      child: Text(
        renja.statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

Widget _buildInfoChip({required IconData icon, required String label}) {
  return Container(
    padding: _paddingSmall,
    decoration: BoxDecoration(
      color: _infoBgColor.withValues(alpha: 0.08),
      borderRadius: _borderRadiusSmallRadius,
      border: Border.all(color: _infoTextColor.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _infoTextColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _infoTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _BengkelFilterDropdown extends StatelessWidget {
  const _BengkelFilterDropdown();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();
    return Column(
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
          child: Obx(
            () => c.loadingBengkel.value
                ? const Center(child: CircularProgressIndicator())
                : Obx(
                    () => DropdownButton<String?>(
                      isExpanded: true,
                      value: c.selectedShafUuid.value,
                      hint: const Text('Bengkel'),
                      items: _buildDropdownItems(c),
                      onChanged: (v) => c.selectedShafUuid.value = v,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  static List<DropdownMenuItem<String?>> _buildDropdownItems(
    RenjaController c,
  ) {
    return [
      const DropdownMenuItem<String?>(value: null, child: Text('All')),
      ...c.bengkelList.map(
        (b) => DropdownMenuItem<String?>(
          value: b.uuid,
          child: Text(b.bengkelName),
        ),
      ),
    ];
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();
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
      final years = c.items.map((e) => e.tahunHijriah).toSet().toList()..sort();
      final months = HijriahMonth.values.toList()
        ..sort((a, b) => a.asString.compareTo(b.asString));
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
                  'Instansi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButton<Instansi?>(
                    isExpanded: true,
                    value: c.selectedInstansi.value,
                    hint: const Text('Instansi'),
                    items: [
                      const DropdownMenuItem<Instansi?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...Instansi.values.map(
                        (e) => DropdownMenuItem<Instansi?>(
                          value: e,
                          child: Text(e.asString),
                        ),
                      ),
                    ],
                    onChanged: (v) => c.selectedInstansi.value = v,
                  ),
                ),
              ],
            ),
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
                  width: 150,
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: c.selectedTahunHijriah.value,
                    hint: const Text('Tahun Hijriah'),
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
                  width: 170,
                  child: DropdownButton<HijriahMonth?>(
                    isExpanded: true,
                    value: c.selectedBulanHijriah.value,
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
                    onChanged: (v) => c.selectedBulanHijriah.value = v,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButton<bool?>(
                    isExpanded: true,
                    value: c.selectedTergelar.value,
                    hint: const Text('Status'),
                    items: const [
                      DropdownMenuItem<bool?>(value: null, child: Text('All')),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text('Tergelar'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text('Tidak tergelar'),
                      ),
                    ],
                    onChanged: (v) => c.selectedTergelar.value = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showFilterDialog(BuildContext context, RenjaController c) {
    final years = c.items.map((e) => e.tahunHijriah).toSet().toList()..sort();
    final months = HijriahMonth.values.toList()
      ..sort((a, b) => a.asString.compareTo(b.asString));

    showModalBottomSheet(
      context: context,
      builder: (context) =>
          _FilterDialogContent(controller: c, years: years, months: months),
    );
  }
}

class _FilterDialogContent extends StatelessWidget {
  final RenjaController controller;
  final List<int> years;
  final List<HijriahMonth> months;

  const _FilterDialogContent({
    required this.controller,
    required this.years,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                      value: controller.selectedShafUuid.value,
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
                      onChanged: (v) => controller.selectedShafUuid.value = v,
                    ),
              const SizedBox(height: 16),
              Text(
                'Instansi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<Instansi?>(
                isExpanded: true,
                value: controller.selectedInstansi.value,
                hint: const Text('Instansi'),
                items: [
                  const DropdownMenuItem<Instansi?>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...Instansi.values.map(
                    (e) => DropdownMenuItem<Instansi?>(
                      value: e,
                      child: Text(e.asString),
                    ),
                  ),
                ],
                onChanged: (v) => controller.selectedInstansi.value = v,
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
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<bool?>(
                isExpanded: true,
                value: controller.selectedTergelar.value,
                hint: const Text('Status'),
                items: const [
                  DropdownMenuItem<bool?>(value: null, child: Text('All')),
                  DropdownMenuItem<bool?>(value: true, child: Text('Tergelar')),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text('Tidak tergelar'),
                  ),
                ],
                onChanged: (v) => controller.selectedTergelar.value = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonDialog extends StatelessWidget {
  const _ReasonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return AlertDialog(
      title: const Text('Alasan tidak tergelar'),
      content: TextField(
        controller: ctrl,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Tuliskan alasan... (wajib)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: ctrl.text.trim()),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

Future<void> _exportExcel({
  required List<Renja> items,
  HijriahMonth? bulan,
  int? tahun,
  Instansi? instansiFilter,
}) async {
  try {
    final wb = xls.Workbook();
    final ws = wb.worksheets[0];

    // Title and subtitle
    final shafSet = items.map((e) => e.shaf?.name).whereType<String>().toSet();
    final shafLabel = shafSet.length == 1 ? shafSet.first : 'AC';
    final monthText =
        (bulan ?? (items.isNotEmpty ? items.first.bulanHijriah : null))
            ?.asString ??
        '';
    final yearText =
        (tahun ?? (items.isNotEmpty ? items.first.tahunHijriah : null))
            ?.toString() ??
        '';

    ws.getRangeByName('A1:Q1').merge();
    final titleRange = ws.getRangeByName('A1');
    titleRange.setText('RENCANA KERJA $shafLabel');
    final titleStyle = wb.styles.add('title');
    titleStyle.bold = true;
    titleStyle.fontSize = 18;
    titleStyle.fontColor = '#1B5E20';
    titleStyle.hAlign = xls.HAlignType.center;
    ws.getRangeByName('A1:Q1').cellStyle = titleStyle;

    ws.getRangeByName('A2:Q2').merge();
    final subtitle = ws.getRangeByName('A2');
    subtitle.setText('$monthText $yearText');
    final subtitleStyle = wb.styles.add('subtitle');
    subtitleStyle.bold = true;
    subtitleStyle.fontSize = 14;
    subtitleStyle.fontColor = '#1B5E20';
    subtitleStyle.hAlign = xls.HAlignType.center;
    ws.getRangeByName('A2:Q2').cellStyle = subtitleStyle;

    // Optional: show current Instansi filter text at A3
    if (instansiFilter != null) {
      ws.getRangeByName('A3:Q3').merge();
      ws.getRangeByName('A3').setText('DIVISI: ${instansiFilter.asString}');
    }

    // Start table header at row 5
    const startRow = 5;
    final headers = <String>[
      'NO',
      'HIJRIYAH',
      'MASEHI',
      'HARI',
      'JAM',
      'JENIS KEGIATAN',
      'TITIK',
      'P.JAWAB',
      'SASARAN',
      'TUJUAN',
      'TARGET',
      'VOLUME',
      'INSTANSI',
      'ANGGARAN',
    ];

    // Header row with color + enable AutoFilter
    for (var i = 0; i < headers.length; i++) {
      ws.getRangeByIndex(startRow, i + 1).setText(headers[i]);
    }
    final headerStyle = wb.styles.add('header');
    headerStyle.backColor = '#009688';
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.bold = true;
    ws.getRangeByName('A$startRow:N$startRow').cellStyle =
        headerStyle; // 14 cols -> N

    // Data rows start at startRow + 1
    for (var i = 0; i < items.length; i++) {
      final r = items[i];
      final row = startRow + 1 + i;

      // Parse date and compute localized day + Hijriyah
      DateTime? d;
      try {
        d = DateTime.parse(r.date).toLocal();
      } catch (_) {
        try {
          d = DateFormat('yyyy-MM-dd').parse(r.date).toLocal();
        } catch (_) {}
      }
      final hari = d != null ? DateFormat('EEEE', 'id_ID').format(d) : '';
      final hijText = d != null
          ? Hijriyah.fromDate(d, isPasaran: false).toFormat("dd MMMM yyyy")
          : '${r.day} ${r.bulanHijriah.asString} ${r.tahunHijriah}';

      // Columns mapping
      ws.getRangeByIndex(row, 1).setNumber((i + 1).toDouble()); // NO
      ws.getRangeByIndex(row, 2).setText(hijText); // HIJRIYAH (computed)
      ws.getRangeByIndex(row, 3).setText(r.date); // MASEHI
      ws.getRangeByIndex(row, 4).setText(hari); // HARI localized
      ws.getRangeByIndex(row, 5).setText(r.time); // JAM
      ws.getRangeByIndex(row, 6).setText(r.kegiatanDesc); // JENIS KEGIATAN
      ws.getRangeByIndex(row, 7).setText(r.titikDesc); // TITIK
      ws.getRangeByIndex(row, 8).setText(r.pic); // P.JAWAB
      ws.getRangeByIndex(row, 9).setText(r.sasaran); // SASARAN
      ws.getRangeByIndex(row, 10).setText(r.tujuan); // TUJUAN
      ws.getRangeByIndex(row, 11).setText(r.target); // TARGET
      ws.getRangeByIndex(row, 12).setNumber(r.volume); // VOLUME
      ws.getRangeByIndex(row, 13).setText(r.instansi.asString); // INSTANSI
      ws.getRangeByIndex(row, 14).setNumber(r.cost.toDouble()); // ANGGARAN
    }

    // Auto fit columns individually
    for (var c = 1; c <= headers.length; c++) {
      ws.autoFitColumn(c);
    }

    // Enable AutoFilter on header row
    ws.autoFilters.filterRange = ws.getRangeByName('A$startRow:N$startRow');
    // Freeze the title, subtitle, (optional) instansi row, and header row + columns A..F
    ws.getRangeByName('G${startRow + 1}').freezePanes();

    final bytes = wb.saveAsStream();
    wb.dispose();

    const fileName = 'renja_export.xlsx';
    final result = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Excel Workbook', extensions: ['xlsx']),
      ],
    );
    if (result == null) return;

    final xfile = XFile.fromData(
      Uint8List.fromList(bytes),
      name: fileName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    await xfile.saveTo(result.path);

    Get.snackbar(
      'Export selesai',
      'File disimpan ke: ${result.path}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  } catch (e) {
    Get.snackbar(
      'Export gagal',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }
}

// Helper functions removed - now using computed properties in Renja model
// This eliminates 1,800+ DateTime.parse() calls per second during scrolling

// GetX Controller for Tergelar Dialog
class _TergelarDialogController extends GetxController {
  final showReasonField = false.obs;
  final reasonCtrl = TextEditingController();

  void toggleReasonField() {
    showReasonField.toggle();
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}

Future<void> _showTergelarDialog(BuildContext context, Renja renja) async {
  final controller = Get.put(_TergelarDialogController());

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Set Tergelar Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              renja.kegiatanDesc,
              style: Theme.of(ctx).textTheme.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Obx(
              () => !controller.showReasonField.value
                  ? Column(
                      children: [
                        const Text('Select status:'),
                        const SizedBox(height: 12),
                        // Tergelar button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Tergelar'),
                            onPressed: () async {
                              final updated = renja.copyWith(
                                isTergelar: true,
                                reasonTidakTergelar: null,
                              );
                              final c = Get.find<RenjaController>();
                              await c.updateItem(updated);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Tidak Tergelar button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.cancel),
                            label: const Text('Tidak Tergelar'),
                            onPressed: () {
                              controller.toggleReasonField();
                            },
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text('Reason for not completed:'),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller.reasonCtrl,
                          maxLines: 3,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter reason...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        Obx(
          () => controller.showReasonField.value
              ? TextButton(
                  onPressed: () {
                    controller.toggleReasonField();
                  },
                  child: const Text('Back'),
                )
              : const SizedBox.shrink(),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        Obx(
          () => controller.showReasonField.value
              ? FilledButton(
                  onPressed: () async {
                    if (controller.reasonCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Please enter a reason')),
                      );
                      return;
                    }
                    final updated = renja.copyWith(
                      isTergelar: false,
                      reasonTidakTergelar: controller.reasonCtrl.text.trim(),
                    );
                    final c = Get.find<RenjaController>();
                    await c.updateItem(updated);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );

  // Clean up the controller when dialog is closed
  Get.delete<_TergelarDialogController>();
}
