import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';
import 'renja_controller.dart';
import 'renja_form_page.dart';

class RenjaListPage extends StatelessWidget {
  const RenjaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renja Management'),
        actions: [
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
                            '${r.date} ${r.time} • ${r.instansi.asString}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: leading + days,
              itemBuilder: (context, index) {
                if (index < leading) return const SizedBox.shrink();
                final day = index - leading + 1;
                final date = DateTime(month.year, month.month, day);
                final iso = isoFmt.format(date);
                final items = c.filteredItems
                    .where((r) => r.date == iso)
                    .toList();
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
                                  if (r.sasaran.isNotEmpty)
                                    Text('Sasaran: ${r.sasaran}'),
                                  if (r.tujuan.isNotEmpty)
                                    Text('Tujuan: ${r.tujuan}'),
                                  if (r.target.isNotEmpty)
                                    Text('Target: ${r.target}'),
                                  if (r.pic.isNotEmpty) Text('PIC: ${r.pic}'),
                                  if (r.titikDesc.isNotEmpty)
                                    Text('Titik: ${r.titikDesc}'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: has ? Colors.teal.withValues(alpha: 0.08) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: 6, right: 6, child: Text('$day')),
                        // Show up to three kegiatan labels, color-coded by instansi
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 22,
                              left: 4,
                              right: 4,
                              bottom: 14,
                            ),
                            child: has
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...items
                                          .take(3)
                                          .map(
                                            (e) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 2,
                                              ),
                                              child: Text(
                                                e.kegiatanDesc,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _instansiColor(
                                                    e.instansi,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      if (items.length > 3)
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
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
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
              },
            ),
          ),
        ],
      );
    });
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
            SizedBox(
              width: 150,
              child: DropdownButton<int?>(
                isExpanded: true,
                value: c.selectedTahunHijriah.value,
                hint: const Text('Tahun Hijriah'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All')),
                  ...years.map(
                    (y) => DropdownMenuItem<int?>(value: y, child: Text('$y')),
                  ),
                ],
                onChanged: (v) => c.selectedTahunHijriah.value = v,
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
      );
    });
  }
}
