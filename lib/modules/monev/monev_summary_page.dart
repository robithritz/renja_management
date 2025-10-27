import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/monev_summary.dart';
import '../../data/repositories/monev_repository.dart';
import '../../data/repositories/monev_api_repository.dart';
import '../../shared/enums/hijriah_month.dart';
import 'monev_controller.dart';

class MonevSummaryPage extends StatelessWidget {
  const MonevSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MonevRepository>()) {
      Get.put(MonevRepository(), permanent: true);
    }
    if (!Get.isRegistered<MonevApiRepository>()) {
      Get.put(MonevApiRepository(), permanent: true);
    }
    if (!Get.isRegistered<MonevController>()) {
      Get.put(
        MonevController(
          Get.find<MonevApiRepository>(),
          Get.find<MonevRepository>(),
        ),
        permanent: true,
      );
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
                  child: Obx(() {
                    final years =
                        c.availableMonthYears
                            .map((m) => m['tahun_hijriah'] as int)
                            .toSet()
                            .toList()
                          ..sort((a, b) => b.compareTo(a));
                    final months = HijriahMonth.values.toList()
                      ..sort((a, b) => a.asString.compareTo(b.asString));
                    const pekanNumbers = [1, 2, 3, 4];

                    // Ensure selected year is in the list or reset to null
                    if (c.selectedTahunHijriah.value != null &&
                        !years.contains(c.selectedTahunHijriah.value)) {
                      c.selectedTahunHijriah.value = null;
                    }

                    // Ensure selected month is valid or reset to null
                    if (c.selectedBulanHijriah.value != null &&
                        !months.contains(c.selectedBulanHijriah.value)) {
                      c.selectedBulanHijriah.value = null;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Bengkel Filter
                        Text(
                          'Bengkel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        c.loadingBengkel.value
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButton<String?>(
                                isExpanded: true,
                                value: c.selectedBengkelUuid.value,
                                hint: const Text('Bengkel'),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  ...c.bengkelList.map(
                                    (b) => DropdownMenuItem<String?>(
                                      value: b.uuid,
                                      child: Text(b.bengkelName),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    c.selectedBengkelUuid.value = v,
                              ),
                        const SizedBox(height: 16),
                        // Tahun Hijriah Filter
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
                          hint: const Text('Tahun'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...years.map(
                              (y) => DropdownMenuItem<int?>(
                                value: y,
                                child: Text('$y'),
                              ),
                            ),
                          ],
                          onChanged: (v) => c.selectedTahunHijriah.value = v,
                        ),
                        const SizedBox(height: 16),
                        // Bulan Hijriah Filter
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
                          hint: const Text('Bulan'),
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
                        // Pekan Filter
                        Text(
                          'Pekan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int?>(
                          isExpanded: true,
                          value: c.selectedPekan.value,
                          hint: const Text('Pekan'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                            ...pekanNumbers.map(
                              (p) => DropdownMenuItem<int?>(
                                value: p,
                                child: Text('$p'),
                              ),
                            ),
                          ],
                          onChanged: (v) => c.selectedPekan.value = v,
                        ),
                      ],
                    );
                  }),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (summary.shafName != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF135193,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF135193,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      summary.shafName!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF135193),
                                      ),
                                    ),
                                  ),
                              ],
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
    final c = Get.find<MonevController>();
    final monevList = c.summaryMonevList;

    final shafNarrations = <String, Map<String, String?>>{};

    // Extract narrations from the API response data (from shaf attribute)
    for (final monev in monevList) {
      if (monev.bulanHijriah == bulan &&
          monev.tahunHijriah == tahun &&
          monev.weekNumber == pekan &&
          monev.shafUuid != null &&
          monev.shaf != null) {
        final bengkelName = monev.shaf!.bengkelName;
        shafNarrations[bengkelName] = {
          'mal': monev.narrationMal,
          'bn': monev.narrationBn,
          'dkw': monev.narrationDkw,
        };
      }
    }

    return shafNarrations;
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatSummaryText(
    MonevSummary summary, [
    Map<String, Map<String, String?>>? shafNarrations,
  ]) {
    final mal = summary.totalActiveMal;
    final bn = summary.totalActiveBn;
    final newMember = summary.totalNewMember;
    final kdpu = summary.totalKdpu;
    final nominal = _formatCurrency(summary.nominalMal);
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
• Total: $mal ($malPct%)$malNarasi

*BN (${summary.totalActiveBn}):*
• Kelas A: ${summary.activeBnClassA}/${summary.totalClassA} ($bnClassAPct%)
• Kelas B: ${summary.activeBnClassB}/${summary.totalClassB} ($bnClassBPct%)
• Kelas C: ${summary.activeBnClassC}/${summary.totalClassC} ($bnClassCPct%)
• Kelas D: ${summary.activeBnClassD}/${summary.totalClassD} ($bnClassDPct%)
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
