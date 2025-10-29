import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/monev.dart';
import '../../shared/enums/hijriah_month.dart';
import 'monev_controller.dart';
import '../../data/repositories/shaf_api_repository.dart';
import '../../data/models/shaf_entity.dart';

// GetX Controller for Monev Form
class MonevFormController extends GetxController {
  final Monev? initial;
  MonevFormController({this.initial});

  final formKey = GlobalKey<FormState>();

  final bulan = Rx<HijriahMonth>(HijriahMonth.muharram);
  final tahun = TextEditingController(text: '1447');
  final week = Rx<int>(1);
  final selectedShafUuid = Rxn<String>();
  final selectedShaf = Rxn<ShafEntity>();
  final shafList = Rx<List<ShafEntity>>([]);

  final malPu = TextEditingController(text: '0');
  final malA = TextEditingController(text: '0');
  final malB = TextEditingController(text: '0');
  final malC = TextEditingController(text: '0');
  final malD = TextEditingController(text: '0');
  final nomMal = TextEditingController(text: '0');

  final bnPu = TextEditingController(text: '0');
  final bnA = TextEditingController(text: '0');
  final bnB = TextEditingController(text: '0');
  final bnC = TextEditingController(text: '0');
  final bnD = TextEditingController(text: '0');

  final newMember = TextEditingController(text: '0');
  final kdpu = TextEditingController(text: '0');

  final narrationMal = TextEditingController();
  final narrationBn = TextEditingController();
  final narrationDkw = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeFormData();
    _attachPctListeners();
    _loadShaf();
  }

  void _initializeFormData() {
    final e = initial;
    if (e != null) {
      bulan.value = e.bulanHijriah;
      tahun.text = e.tahunHijriah.toString();
      week.value = e.weekNumber;
      selectedShafUuid.value = e.shafUuid;
      malPu.text = e.activeMalPu.toString();
      malA.text = e.activeMalClassA.toString();
      malB.text = e.activeMalClassB.toString();
      malC.text = e.activeMalClassC.toString();
      malD.text = e.activeMalClassD.toString();
      nomMal.text = e.nominalMal.toString();
      bnPu.text = e.activeBnPu.toString();
      bnA.text = e.activeBnClassA.toString();
      bnB.text = e.activeBnClassB.toString();
      bnC.text = e.activeBnClassC.toString();
      bnD.text = e.activeBnClassD.toString();
      newMember.text = e.totalNewMember.toString();
      kdpu.text = e.totalKdpu.toString();
      narrationMal.text = e.narrationMal ?? '';
      narrationBn.text = e.narrationBn ?? '';
      narrationDkw.text = e.narrationDkw ?? '';
    }
  }

  @override
  void onClose() {
    tahun.dispose();
    malPu.dispose();
    malA.dispose();
    malB.dispose();
    malC.dispose();
    malD.dispose();
    nomMal.dispose();
    bnPu.dispose();
    bnA.dispose();
    bnB.dispose();
    bnC.dispose();
    bnD.dispose();
    newMember.dispose();
    kdpu.dispose();
    narrationMal.dispose();
    narrationBn.dispose();
    narrationDkw.dispose();
    super.onClose();
  }

  Future<void> _loadShaf() async {
    try {
      final repo = Get.isRegistered<ShafApiRepository>()
          ? Get.find<ShafApiRepository>()
          : Get.put(ShafApiRepository(), permanent: true);
      final response = await repo.getAll(bengkelType: 'rakit');
      final list = response['data'] as List<ShafEntity>;
      shafList.value = list;
      if (selectedShafUuid.value != null) {
        selectedShaf.value = shafList.value.firstWhereOrNull(
          (s) => s.uuid == selectedShafUuid.value,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shaf list: $e');
      shafList.value = [];
    }
  }

  void _attachPctListeners() {
    for (final c in [
      malPu,
      malA,
      malB,
      malC,
      malD,
      bnPu,
      bnA,
      bnB,
      bnC,
      bnD,
      newMember,
      kdpu,
    ]) {
      c.addListener(() {
        update();
      });
    }
  }

  String fmtPct(int num, int? denom) {
    if (denom == null || denom <= 0) return '-';
    final v = (num / denom) * 100;
    return '${v.toStringAsFixed(1)}%';
  }

  int val(TextEditingController c) => int.tryParse(c.text) ?? 0;
}

class MonevFormPage extends StatelessWidget {
  const MonevFormPage({super.key, this.initial});
  final Monev? initial;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonevFormController(initial: initial));
    final c = Get.find<MonevController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(initial == null ? 'Tambah Monev' : 'Edit Monev'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Column(
                  children: [
                    _bulanDropdown(controller),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.tahun,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Hijriah',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    _weekDropdown(controller),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedShafUuid.value,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Shaf',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Shaf'),
                    items: controller.shafList.value
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.uuid,
                            child: Text(s.bengkelName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      controller.selectedShafUuid.value = v;
                      if (v != null) {
                        controller.selectedShaf.value = controller
                            .shafList
                            .value
                            .firstWhereOrNull((s) => s.uuid == v);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('MAL'),
                const SizedBox(height: 8),
                GetBuilder<MonevFormController>(
                  builder: (ctrl) => Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.malPu,
                              'PU Aktif',
                              ctrl.selectedShaf.value?.totalPu,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _numWithPct(
                              ctrl.malA,
                              'Kelas A',
                              ctrl.selectedShaf.value?.totalClassA,
                              ctrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.malB,
                              'Kelas B',
                              ctrl.selectedShaf.value?.totalClassB,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _numWithPct(
                              ctrl.malC,
                              'Kelas C',
                              ctrl.selectedShaf.value?.totalClassC,
                              ctrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.malD,
                              'Kelas D',
                              ctrl.selectedShaf.value?.totalClassD,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _numField(ctrl.nomMal, 'Nominal (Rp)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctrl.narrationMal,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Narasi MAL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('BN'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.bnPu,
                              'PU Aktif',
                              ctrl.selectedShaf.value?.totalPu,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _numWithPct(
                              ctrl.bnA,
                              'Kelas A',
                              ctrl.selectedShaf.value?.totalClassA,
                              ctrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.bnB,
                              'Kelas B',
                              ctrl.selectedShaf.value?.totalClassB,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _numWithPct(
                              ctrl.bnC,
                              'Kelas C',
                              ctrl.selectedShaf.value?.totalClassC,
                              ctrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _numWithPct(
                              ctrl.bnD,
                              'Kelas D',
                              ctrl.selectedShaf.value?.totalClassD,
                              ctrl,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctrl.narrationBn,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Narasi BN',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _numField(ctrl.newMember, 'Anggota Baru'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _numField(ctrl.kdpu, 'KDPU')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ctrl.narrationDkw,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Narasi DKW',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text('Batal'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () async {
                              if (!controller.formKey.currentState!
                                  .validate()) {
                                return;
                              }
                              if (initial == null) {
                                await c.create(
                                  bulanHijriah: ctrl.bulan.value,
                                  tahunHijriah:
                                      int.tryParse(ctrl.tahun.text) ?? 1447,
                                  weekNumber: ctrl.week.value,
                                  shafUuid: ctrl.selectedShafUuid.value ?? '',
                                  activeMalPu:
                                      int.tryParse(ctrl.malPu.text) ?? 0,
                                  activeMalClassA:
                                      int.tryParse(ctrl.malA.text) ?? 0,
                                  activeMalClassB:
                                      int.tryParse(ctrl.malB.text) ?? 0,
                                  activeMalClassC:
                                      int.tryParse(ctrl.malC.text) ?? 0,
                                  activeMalClassD:
                                      int.tryParse(ctrl.malD.text) ?? 0,
                                  nominalMal:
                                      int.tryParse(ctrl.nomMal.text) ?? 0,
                                  activeBnPu: int.tryParse(ctrl.bnPu.text) ?? 0,
                                  activeBnClassA:
                                      int.tryParse(ctrl.bnA.text) ?? 0,
                                  activeBnClassB:
                                      int.tryParse(ctrl.bnB.text) ?? 0,
                                  activeBnClassC:
                                      int.tryParse(ctrl.bnC.text) ?? 0,
                                  activeBnClassD:
                                      int.tryParse(ctrl.bnD.text) ?? 0,
                                  totalNewMember:
                                      int.tryParse(ctrl.newMember.text) ?? 0,
                                  totalKdpu: int.tryParse(ctrl.kdpu.text) ?? 0,
                                  narrationMal:
                                      ctrl.narrationMal.text.trim().isEmpty
                                      ? null
                                      : ctrl.narrationMal.text.trim(),
                                  narrationBn:
                                      ctrl.narrationBn.text.trim().isEmpty
                                      ? null
                                      : ctrl.narrationBn.text.trim(),
                                  narrationDkw:
                                      ctrl.narrationDkw.text.trim().isEmpty
                                      ? null
                                      : ctrl.narrationDkw.text.trim(),
                                );
                              } else {
                                await c.updateItem(
                                  initial!.copyWith(
                                    bulanHijriah: ctrl.bulan.value,
                                    tahunHijriah:
                                        int.tryParse(ctrl.tahun.text) ?? 1447,
                                    weekNumber: ctrl.week.value,
                                    shafUuid: ctrl.selectedShafUuid.value ?? '',
                                    activeMalPu:
                                        int.tryParse(ctrl.malPu.text) ?? 0,
                                    activeMalClassA:
                                        int.tryParse(ctrl.malA.text) ?? 0,
                                    activeMalClassB:
                                        int.tryParse(ctrl.malB.text) ?? 0,
                                    activeMalClassC:
                                        int.tryParse(ctrl.malC.text) ?? 0,
                                    activeMalClassD:
                                        int.tryParse(ctrl.malD.text) ?? 0,
                                    nominalMal:
                                        int.tryParse(ctrl.nomMal.text) ?? 0,
                                    activeBnPu:
                                        int.tryParse(ctrl.bnPu.text) ?? 0,
                                    activeBnClassA:
                                        int.tryParse(ctrl.bnA.text) ?? 0,
                                    activeBnClassB:
                                        int.tryParse(ctrl.bnB.text) ?? 0,
                                    activeBnClassC:
                                        int.tryParse(ctrl.bnC.text) ?? 0,
                                    activeBnClassD:
                                        int.tryParse(ctrl.bnD.text) ?? 0,
                                    totalNewMember:
                                        int.tryParse(ctrl.newMember.text) ?? 0,
                                    totalKdpu:
                                        int.tryParse(ctrl.kdpu.text) ?? 0,
                                    narrationMal:
                                        ctrl.narrationMal.text.trim().isEmpty
                                        ? null
                                        : ctrl.narrationMal.text.trim(),
                                    narrationBn:
                                        ctrl.narrationBn.text.trim().isEmpty
                                        ? null
                                        : ctrl.narrationBn.text.trim(),
                                    narrationDkw:
                                        ctrl.narrationDkw.text.trim().isEmpty
                                        ? null
                                        : ctrl.narrationDkw.text.trim(),
                                  ),
                                );
                              }
                              Get.back();
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _bulanDropdown(MonevFormController controller) {
    return Obx(
      () => DropdownButtonFormField<HijriahMonth>(
        value: controller.bulan.value,
        decoration: const InputDecoration(
          labelText: 'Bulan Hijriah',
          border: OutlineInputBorder(),
        ),
        items: HijriahMonth.values
            .map((e) => DropdownMenuItem(value: e, child: Text(e.asString)))
            .toList(),
        onChanged: (v) {
          if (v != null) controller.bulan.value = v;
        },
      ),
    );
  }

  static Widget _weekDropdown(MonevFormController controller) {
    return Obx(
      () => DropdownButtonFormField<int>(
        value: controller.week.value,
        decoration: const InputDecoration(
          labelText: 'Pekan Ke-',
          border: OutlineInputBorder(),
        ),
        items: const [1, 2, 3, 4]
            .map((e) => DropdownMenuItem(value: e, child: Text('Pekan $e')))
            .toList(),
        onChanged: (v) {
          if (v != null) controller.week.value = v;
        },
      ),
    );
  }

  static Widget _numField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  static Widget _numWithPct(
    TextEditingController c,
    String label,
    int? denom,
    MonevFormController controller,
  ) {
    return Row(
      children: [
        Expanded(child: _numField(c, label)),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            controller.fmtPct(controller.val(c), denom),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
