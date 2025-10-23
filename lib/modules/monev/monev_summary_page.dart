import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/monev_summary.dart';
import '../../data/repositories/monev_repository.dart';
import '../../shared/enums/hijriah_month.dart';
import 'monev_controller.dart';

class MonevSummaryPage extends StatelessWidget {
  const MonevSummaryPage({super.key});

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
        title: const Text('Ringkasan Monev'),
        actions: [
          Obx(() {
            final summary = c.currentSummary.value;
            return IconButton(
              icon: const Icon(Icons.share),
              onPressed: summary != null
                  ? () => _shareToWhatsApp(summary, c)
                  : null,
              tooltip: 'Bagikan ke WhatsApp',
            );
          }),
        ],
      ),
      body: Obx(() {
        if (c.availableMonthYears.isEmpty) {
          return const Center(child: Text('Belum ada data Monev'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Bulan & Tahun Hijriah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<HijriahMonth>(
                              isExpanded: true,
                              value: c.selectedMonth.value,
                              items: HijriahMonth.values
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m.asString),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (month) {
                                if (month != null &&
                                    c.selectedYear.value != null) {
                                  c.selectMonthYear(
                                    month,
                                    c.selectedYear.value!,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: c.selectedYear.value,
                              items: _getYearDropdownItems(
                                c.availableMonthYears,
                              ),
                              onChanged: (year) {
                                if (year != null &&
                                    c.selectedMonth.value != null) {
                                  c.selectMonthYear(
                                    c.selectedMonth.value!,
                                    year,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Filter Shaf',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final shafs = c.availableShafs;
                        return DropdownButton<String?>(
                          isExpanded: true,
                          value: c.selectedShafUuid.value,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Semua Shaf'),
                            ),
                            ...shafs.map(
                              (s) => DropdownMenuItem(
                                value: s.uuid,
                                child: Text('${s.asiaName} — ${s.rakitName}'),
                              ),
                            ),
                          ],
                          onChanged: (shafUuid) {
                            c.selectShaf(shafUuid);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary Data
              Obx(() {
                if (c.summaryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final summary = c.currentSummary.value;
                if (summary == null) {
                  return const Center(
                    child: Text('Tidak ada data untuk periode ini'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pekan ${summary.latestWeekNumber} - ${summary.bulanHijriah.asString} ${summary.tahunHijriah}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Data terbaru dari pekan yang diinput',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // MAL Chart
                    const Text(
                      'Aktif MAL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBarChart(
                          [
                            summary.activeMalPu.toDouble(),
                            summary.activeMalClassA.toDouble(),
                            summary.activeMalClassB.toDouble(),
                            summary.activeMalClassC.toDouble(),
                            summary.activeMalClassD.toDouble(),
                          ],
                          ['PU', 'Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BN Chart
                    const Text(
                      'Aktif BN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBarChart(
                          [
                            summary.activeBnPu.toDouble(),
                            summary.activeBnClassA.toDouble(),
                            summary.activeBnClassB.toDouble(),
                            summary.activeBnClassC.toDouble(),
                            summary.activeBnClassD.toDouble(),
                          ],
                          ['PU', 'Kelas A', 'Kelas B', 'Kelas C', 'Kelas D'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Activation Percentage Pie Charts
                    const Text(
                      'Persentase Aktivasi Anggota',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildActivationPieChart(
                                'MAL',
                                summary.totalActiveMal,
                                summary.totalPu,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildActivationPieChart(
                                'BN',
                                summary.totalActiveBn,
                                summary.totalPu,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Summary Stats
                    const Text(
                      'Ringkasan Statistik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      children: [
                        _buildStatCard(
                          'Total MAL',
                          summary.totalActiveMal.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Total BN',
                          summary.totalActiveBn.toString(),
                          Colors.green,
                        ),
                        // _buildStatCard(
                        //   'Total Aktif',
                        //   summary.totalActive.toString(),
                        //   Colors.purple,
                        // ),
                        _buildStatCard(
                          'Anggota Baru',
                          summary.totalNewMember.toString(),
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Total KDPU',
                          summary.totalKdpu.toString(),
                          Colors.red,
                        ),
                        _buildStatCard(
                          'Nominal MAL',
                          'Rp ${summary.nominalMal}',
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Narration Section
                    FutureBuilder<Widget>(
                      future: _buildNarrationSection(summary, c),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        return snapshot.data ?? const SizedBox.shrink();
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBarChart(List<double> values, List<String> labels) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: values.isEmpty
              ? 10
              : (values.reduce((a, b) => a > b ? a : b) * 1.2),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < labels.length) {
                    return Text(labels[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _getYearDropdownItems(
    List<Map<String, dynamic>> availableMonthYears,
  ) {
    final years =
        availableMonthYears
            .map((m) => m['tahun_hijriah'] as int)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return years
        .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
        .toList();
  }

  Widget _buildActivationPieChart(
    String label,
    int activeCount,
    int totalPotential,
  ) {
    // Calculate inactive count based on total potential
    final inactiveCount = (totalPotential - activeCount).clamp(
      0,
      totalPotential,
    );
    final activationPercentage = totalPotential > 0
        ? (activeCount / totalPotential * 100).toStringAsFixed(1)
        : '0.0';
    final inactivePercentage = (100 - double.parse(activationPercentage))
        .toStringAsFixed(1);

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: activeCount.toDouble(),
                  title: '$activationPercentage%',
                  color: Colors.green,
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: inactiveCount.toDouble(),
                  title: '$inactivePercentage%',
                  color: Colors.grey[300]!,
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Aktif: $activeCount',
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tidak Aktif: $inactiveCount',
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> _buildNarrationSection(
    MonevSummary summary,
    MonevController c,
  ) async {
    // If "semua shaf" is selected, fetch narrations from all shafs
    Map<String, Map<String, String?>>? shafNarrations;
    if (summary.shafUuid == null &&
        c.selectedMonth.value != null &&
        c.selectedYear.value != null) {
      shafNarrations = await _fetchShafNarrations(
        c.selectedMonth.value!,
        c.selectedYear.value!,
        summary.latestWeekNumber,
      );
    }

    // Check if there are any narrations to display
    bool hasNarrations = false;
    if (summary.shafUuid != null) {
      // Single shaf: check summary narrations
      hasNarrations =
          (summary.narrationMal != null && summary.narrationMal!.isNotEmpty) ||
          (summary.narrationBn != null && summary.narrationBn!.isNotEmpty) ||
          (summary.narrationDkw != null && summary.narrationDkw!.isNotEmpty);
    } else {
      // All shafs: check if there are any shaf narrations
      hasNarrations = shafNarrations != null && shafNarrations.isNotEmpty;
    }

    if (!hasNarrations) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Narasi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (summary.shafUuid != null)
          // Single shaf narrations
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary.narrationMal != null &&
                  summary.narrationMal!.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📝 Narasi MAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.narrationMal!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              if (summary.narrationBn != null &&
                  summary.narrationBn!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📝 Narasi BN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary.narrationBn!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (summary.narrationDkw != null &&
                  summary.narrationDkw!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📝 Narasi DKW',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            summary.narrationDkw!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          )
        else if (shafNarrations != null && shafNarrations.isNotEmpty)
          // All shafs narrations
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...shafNarrations.entries.map((entry) {
                final shafName = entry.key;
                final narrations = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🏢 $shafName',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (narrations['mal'] != null &&
                              narrations['mal']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '📝 MAL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    narrations['mal']!,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          if (narrations['bn'] != null &&
                              narrations['bn']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '📝 BN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    narrations['bn']!,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          if (narrations['dkw'] != null &&
                              narrations['dkw']!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📝 DKW',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  narrations['dkw']!,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  Future<void> _shareToWhatsApp(MonevSummary summary, MonevController c) async {
    // If "semua shaf" is selected (shafUuid is null), fetch individual shaf narrations
    Map<String, Map<String, String?>>? shafNarrations;
    if (summary.shafUuid == null &&
        c.selectedMonth.value != null &&
        c.selectedYear.value != null) {
      shafNarrations = await _fetchShafNarrations(
        c.selectedMonth.value!,
        c.selectedYear.value!,
        summary.latestWeekNumber,
      );
    }

    final text = _formatSummaryText(summary, shafNarrations);

    // On macOS, copy to clipboard instead of share
    if (Platform.isMacOS) {
      Clipboard.setData(ClipboardData(text: text));
      Get.snackbar(
        'Berhasil',
        'Ringkasan disalin ke clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      // On Android/iOS, use share dialog
      Share.share(text);
    }
  }

  Future<Map<String, Map<String, String?>>> _fetchShafNarrations(
    HijriahMonth bulan,
    int tahun,
    int pekan,
  ) async {
    final repo = Get.find<MonevRepository>();
    final allMonevs = await repo.getAll();

    final shafNarrations = <String, Map<String, String?>>{};

    // Filter monev records for the selected month/year/pekan
    for (final monev in allMonevs) {
      if (monev.bulanHijriah == bulan &&
          monev.tahunHijriah == tahun &&
          monev.weekNumber == pekan &&
          monev.shafUuid != null &&
          monev.shafName != null) {
        shafNarrations[monev.shafName!] = {
          'mal': monev.narrationMal,
          'bn': monev.narrationBn,
          'dkw': monev.narrationDkw,
        };
      }
    }

    return shafNarrations;
  }

  String _formatSummaryText(
    MonevSummary summary, [
    Map<String, Map<String, String?>>? shafNarrations,
  ]) {
    final mal = summary.totalActiveMal;
    final bn = summary.totalActiveBn;
    final newMember = summary.totalNewMember;
    final kdpu = summary.totalKdpu;
    final nominal = summary.nominalMal;
    final bulan = summary.bulanHijriah.asString;
    final tahun = summary.tahunHijriah;
    final pekan = summary.latestWeekNumber;

    final malPct = summary.totalPu > 0
        ? (mal / summary.totalPu * 100).toStringAsFixed(1)
        : '0.0';

    final bnPct = summary.totalPu > 0
        ? (bn / summary.totalPu * 100).toStringAsFixed(1)
        : '0.0';

    // Calculate class percentages for MAL
    final malClassAPct = summary.totalClassA > 0
        ? (summary.activeMalClassA / summary.totalClassA * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final malClassBPct = summary.totalClassB > 0
        ? (summary.activeMalClassB / summary.totalClassB * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final malClassCPct = summary.totalClassC > 0
        ? (summary.activeMalClassC / summary.totalClassC * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final malClassDPct = summary.totalClassD > 0
        ? (summary.activeMalClassD / summary.totalClassD * 100).toStringAsFixed(
            1,
          )
        : '0.0';

    // Calculate class percentages for BN
    final bnClassAPct = summary.totalClassA > 0
        ? (summary.activeBnClassA / summary.totalClassA * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final bnClassBPct = summary.totalClassB > 0
        ? (summary.activeBnClassB / summary.totalClassB * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final bnClassCPct = summary.totalClassC > 0
        ? (summary.activeBnClassC / summary.totalClassC * 100).toStringAsFixed(
            1,
          )
        : '0.0';
    final bnClassDPct = summary.totalClassD > 0
        ? (summary.activeBnClassD / summary.totalClassD * 100).toStringAsFixed(
            1,
          )
        : '0.0';

    // Get shaf name if single shaf is selected
    final shafInfo = summary.shafUuid != null
        ? '\n🏢 *Shaf:* ${summary.shafName}'
        : '';

    // Build narasi sections if available
    final malNarasi =
        summary.narrationMal != null && summary.narrationMal!.isNotEmpty
        ? '\n\n📝 *Narasi MAL:*\n${summary.narrationMal}'
        : '';
    final bnNarasi =
        summary.narrationBn != null && summary.narrationBn!.isNotEmpty
        ? '\n\n📝 *Narasi BN:*\n${summary.narrationBn}'
        : '';
    final dkwNarasi =
        summary.narrationDkw != null && summary.narrationDkw!.isNotEmpty
        ? '\n\n📝 *Narasi DKW:*\n${summary.narrationDkw}'
        : '';

    // Build shaf narrations section if available (for "semua shaf" view)
    String shafNarationsSection = '';
    if (shafNarrations != null && shafNarrations.isNotEmpty) {
      shafNarationsSection = '\n\n📋 *NARASI PER SHAF:*';
      for (final shafName in shafNarrations.keys) {
        final narrations = shafNarrations[shafName]!;
        shafNarationsSection += '\n\n🏢 *$shafName:*';

        if (narrations['mal'] != null && narrations['mal']!.isNotEmpty) {
          shafNarationsSection += '\n  📝 MAL: ${narrations['mal']}';
        }
        if (narrations['bn'] != null && narrations['bn']!.isNotEmpty) {
          shafNarationsSection += '\n  📝 BN: ${narrations['bn']}';
        }
        if (narrations['dkw'] != null && narrations['dkw']!.isNotEmpty) {
          shafNarationsSection += '\n  📝 DKW: ${narrations['dkw']}';
        }
      }
    }

    return '''
📊 *RINGKASAN MONEV*

📅 *Periode:* Pekan $pekan - $bulan $tahun$shafInfo

👥 *Statistik Anggota:*

*MAL (${summary.totalActiveMal}):*
• Kelas A: ${summary.activeMalClassA}/${summary.totalClassA} ($malClassAPct%)
• Kelas B: ${summary.activeMalClassB}/${summary.totalClassB} ($malClassBPct%)
• Kelas C: ${summary.activeMalClassC}/${summary.totalClassC} ($malClassCPct%)
• Kelas D: ${summary.activeMalClassD}/${summary.totalClassD} ($malClassDPct%)
• PU: ${summary.activeMalPu}
• Total: $mal ($malPct%)$malNarasi

*BN (${summary.totalActiveBn}):*
• Kelas A: ${summary.activeBnClassA}/${summary.totalClassA} ($bnClassAPct%)
• Kelas B: ${summary.activeBnClassB}/${summary.totalClassB} ($bnClassBPct%)
• Kelas C: ${summary.activeBnClassC}/${summary.totalClassC} ($bnClassCPct%)
• Kelas D: ${summary.activeBnClassD}/${summary.totalClassD} ($bnClassDPct%)
• PU: ${summary.activeBnPu}
• Total: $bn ($bnPct%)$bnNarasi

📊 *Lainnya:*
• Anggota Baru: $newMember
• Total KDPU: $kdpu$dkwNarasi

💰 *Nominal MAL:* Rp $nominal$shafNarationsSection

---
Dibuat dari Aplikasi Renja Management
'''
        .trim();
  }
}
