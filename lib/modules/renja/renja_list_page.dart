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
import '../shaf/shaf_list_page.dart';
import '../monev/monev_list_page.dart';

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
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Renja'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Shaf'),
              onTap: () => Get.offAll(() => const ShafListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Monev'),
              onTap: () => Get.offAll(() => const MonevListPage()),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
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
                  ? const Center(child: Text('No data. Tap + to add.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = filtered[i];
                        return ListTile(
                          title: Text(r.kegiatanDesc),
                          subtitle: Text(
                            '${_getDayName(r.date)} ${_formatDate(r.date)} ${r.time} • ${r.instansi.asString}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (r.isTergelar != null)
                                Builder(
                                  builder: (_) {
                                    final msg = r.isTergelar == false
                                        ? (() {
                                            final rs =
                                                r.reasonTidakTergelar?.trim() ??
                                                '';
                                            return rs.isNotEmpty
                                                ? 'Tidak tergelar — $rs'
                                                : 'Tidak tergelar';
                                          })()
                                        : 'Tergelar';
                                    final badge = Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            (r.isTergelar == true
                                                    ? Colors.green
                                                    : Colors.red)
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              (r.isTergelar == true
                                                      ? Colors.green
                                                      : Colors.red)
                                                  .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 220,
                                        ),
                                        child: Text(
                                          msg,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: r.isTergelar == true
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                    return r.isTergelar == false
                                        ? Tooltip(message: msg, child: badge)
                                        : badge;
                                  },
                                ),

                              if ((() {
                                if (r.isTergelar != null) return false;
                                try {
                                  final t = (r.time).trim();
                                  if (t.isNotEmpty) {
                                    final dt = DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).parse('${r.date} $t');
                                    return dt.isBefore(DateTime.now());
                                  } else {
                                    final d = DateFormat(
                                      'yyyy-MM-dd',
                                    ).parse(r.date);
                                    final endOfDay = DateTime(
                                      d.year,
                                      d.month,
                                      d.day,
                                      23,
                                      59,
                                      59,
                                    );
                                    return endOfDay.isBefore(DateTime.now());
                                  }
                                } catch (_) {
                                  try {
                                    final d = DateFormat(
                                      'yyyy-MM-dd',
                                    ).parse(r.date);
                                    final endOfDay = DateTime(
                                      d.year,
                                      d.month,
                                      d.day,
                                      23,
                                      59,
                                      59,
                                    );
                                    return endOfDay.isBefore(DateTime.now());
                                  } catch (_) {
                                    return false;
                                  }
                                }
                              })())
                                IconButton(
                                  tooltip: 'Belum ditandai: Apakah tergelar?',
                                  icon: const Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () async {
                                    final res = await Get.dialog<bool?>(
                                      AlertDialog(
                                        title: const Text('Apakah Tergelar?'),
                                        content: const Text(
                                          'Jadwal ini sudah terlewat. Apakah kegiatan tergelar?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Get.back(result: null),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Get.back(result: false),
                                            child: const Text('Tidak'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Get.back(result: true),
                                            child: const Text('Ya'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (res == true) {
                                      await c.updateItem(
                                        r.copyWith(
                                          isTergelar: true,
                                          reasonTidakTergelar: null,
                                        ),
                                      );
                                    } else if (res == false) {
                                      final reason = await Get.dialog<String?>(
                                        const _ReasonDialog(),
                                      );
                                      if (reason != null &&
                                          reason.trim().isNotEmpty) {
                                        await c.updateItem(
                                          r.copyWith(
                                            isTergelar: false,
                                            reasonTidakTergelar: reason.trim(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await Get.to(
                                    () => RenjaFormPage(existing: r),
                                  );
                                  await c.loadAll();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('Delete?'),
                                      content: Text(
                                        'Delete "${r.kegiatanDesc}"?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await c.deleteItem(r.uuid);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
    final items = c.filteredItems.where((r) => r.date == iso).toList();
    final has = items.isNotEmpty;

    return InkWell(
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
                      if (r.titikDesc.isNotEmpty) Text('Titik: ${r.titikDesc}'),
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
                                final rs = r.reasonTidakTergelar?.trim() ?? '';
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
                    ? SingleChildScrollView(
                        child: Column(
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
                        ),
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
      builder: (context) => Obx(
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

String _getDayName(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[date.weekday % 7];
  } catch (_) {
    return '';
  }
}

String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  } catch (_) {
    return '';
  }
}
