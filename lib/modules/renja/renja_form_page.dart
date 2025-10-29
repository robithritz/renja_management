import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';
import '../../data/models/renja.dart';
import '../../data/models/shaf_entity.dart';
import '../../data/repositories/shaf_api_repository.dart';
import '../../shared/formatters/rupiah_input_formatter.dart';
import 'renja_controller.dart';

// GetX Controller for Renja Form
class RenjaFormController extends GetxController {
  final Renja? existing;
  RenjaFormController({this.existing});

  final formKey = GlobalKey<FormState>();

  final dateCtrl = TextEditingController();
  final bulanHijriah = Rx<HijriahMonth>(HijriahMonth.muharram);
  final tahunHijriahCtrl = TextEditingController();
  final dayCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final kegiatanCtrl = TextEditingController();
  final titikCtrl = TextEditingController();
  final picCtrl = TextEditingController();
  final sasaranCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final tujuanCtrl = TextEditingController();
  final volumeCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  final instansi = Rx<Instansi>(Instansi.EKL);

  final selectedBengkelUuid = Rxn<String>();
  final bengkelList = Rx<List<ShafEntity>>([]);
  final loadingBengkel = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBengkelList();
    _initializeFormData();
  }

  void _initializeFormData() {
    final e = existing;
    if (e != null) {
      dateCtrl.text = e.date;
      bulanHijriah.value = e.bulanHijriah;
      tahunHijriahCtrl.text = e.tahunHijriah.toString();
      dayCtrl.text = e.day.toString();
      timeCtrl.text = e.time;
      kegiatanCtrl.text = e.kegiatanDesc;
      titikCtrl.text = e.titikDesc;
      picCtrl.text = e.pic;
      sasaranCtrl.text = e.sasaran;
      targetCtrl.text = e.target;
      tujuanCtrl.text = e.tujuan;
      volumeCtrl.text = e.volume.toString();
      costCtrl.text = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(e.cost);
      instansi.value = e.instansi;
      selectedBengkelUuid.value = e.shafUuid;
    }
  }

  Future<void> _loadBengkelList() async {
    loadingBengkel.value = true;
    try {
      final repo = ShafApiRepository();
      final response = await repo.getAll();
      bengkelList.value = response['data'] as List<ShafEntity>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bengkel list: $e');
    } finally {
      loadingBengkel.value = false;
    }
  }

  @override
  void onClose() {
    dateCtrl.dispose();
    tahunHijriahCtrl.dispose();
    dayCtrl.dispose();
    timeCtrl.dispose();
    kegiatanCtrl.dispose();
    titikCtrl.dispose();
    picCtrl.dispose();
    sasaranCtrl.dispose();
    targetCtrl.dispose();
    tujuanCtrl.dispose();
    volumeCtrl.dispose();
    costCtrl.dispose();
    super.onClose();
  }
}

class RenjaFormPage extends StatelessWidget {
  const RenjaFormPage({super.key, this.existing});
  final Renja? existing;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RenjaFormController(existing: existing));
    final c = Get.find<RenjaController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Add Renja' : 'Edit Renja'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              _buildBengkelDropdown(controller),
              _text(
                controller.kegiatanCtrl,
                label: 'Kegiatan (desc)',
                required: true,
              ),
              _text(
                controller.dateCtrl,
                label: 'Date (YYYY-MM-DD)',
                required: true,
                onTap: () => _pickDate(context, controller),
              ),
              Row(
                children: [
                  Expanded(child: _dropdownBulanHijriah(controller)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _number(
                      controller.tahunHijriahCtrl,
                      label: 'Tahun Hijriah',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _number(controller.dayCtrl, label: 'Day (1-31)'),
                  ),
                ],
              ),
              _text(
                controller.timeCtrl,
                label: 'Time (HH:mm)',
                onTap: () => _pickTime(context, controller),
              ),
              _text(controller.titikCtrl, label: 'Titik (desc)'),
              _text(controller.picCtrl, label: 'PIC'),
              _text(controller.sasaranCtrl, label: 'Sasaran'),
              _text(controller.targetCtrl, label: 'Target'),
              _text(controller.tujuanCtrl, label: 'Tujuan'),
              _number(controller.volumeCtrl, label: 'Volume'),
              _dropdownInstansi(controller),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: controller.costCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Cost (Rupiah)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!controller.formKey.currentState!.validate()) return;
                  if (existing == null) {
                    await c.create(
                      date: controller.dateCtrl.text.trim(),
                      bulanHijriah: controller.bulanHijriah.value,
                      tahunHijriah:
                          int.tryParse(
                            controller.tahunHijriahCtrl.text.trim(),
                          ) ??
                          0,
                      day: int.tryParse(controller.dayCtrl.text.trim()) ?? 1,
                      time: controller.timeCtrl.text.trim(),
                      kegiatanDesc: controller.kegiatanCtrl.text.trim(),
                      titikDesc: controller.titikCtrl.text.trim(),
                      pic: controller.picCtrl.text.trim(),
                      sasaran: controller.sasaranCtrl.text.trim(),
                      target: controller.targetCtrl.text.trim(),
                      tujuan: controller.tujuanCtrl.text.trim(),
                      volume:
                          double.tryParse(controller.volumeCtrl.text.trim()) ??
                          0,
                      instansi: controller.instansi.value,
                      cost: RupiahInputFormatter.parseToInt(
                        controller.costCtrl.text,
                      ),
                      shafUuid: controller.selectedBengkelUuid.value,
                    );
                  } else {
                    final e = existing!;
                    await c.updateItem(
                      e.copyWith(
                        date: controller.dateCtrl.text.trim(),
                        bulanHijriah: controller.bulanHijriah.value,
                        tahunHijriah:
                            int.tryParse(
                              controller.tahunHijriahCtrl.text.trim(),
                            ) ??
                            e.tahunHijriah,
                        day:
                            int.tryParse(controller.dayCtrl.text.trim()) ??
                            e.day,
                        time: controller.timeCtrl.text.trim(),
                        kegiatanDesc: controller.kegiatanCtrl.text.trim(),
                        titikDesc: controller.titikCtrl.text.trim(),
                        pic: controller.picCtrl.text.trim(),
                        sasaran: controller.sasaranCtrl.text.trim(),
                        target: controller.targetCtrl.text.trim(),
                        tujuan: controller.tujuanCtrl.text.trim(),
                        volume:
                            double.tryParse(
                              controller.volumeCtrl.text.trim(),
                            ) ??
                            e.volume,
                        instansi: controller.instansi.value,
                        cost: RupiahInputFormatter.parseToInt(
                          controller.costCtrl.text,
                        ),
                        shafUuid: controller.selectedBengkelUuid.value,
                      ),
                    );
                  }
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _dropdownBulanHijriah(RenjaFormController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
        () => DropdownButtonFormField<HijriahMonth>(
          value: controller.bulanHijriah.value,
          decoration: const InputDecoration(
            labelText: 'Bulan Hijriah',
            border: OutlineInputBorder(),
          ),
          items: HijriahMonth.values
              .map((m) => DropdownMenuItem(value: m, child: Text(m.asString)))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.bulanHijriah.value = v;
          },
        ),
      ),
    );
  }

  static Widget _dropdownInstansi(RenjaFormController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
        () => DropdownButtonFormField<Instansi>(
          value: controller.instansi.value,
          decoration: const InputDecoration(
            labelText: 'Instansi',
            border: OutlineInputBorder(),
          ),
          items: Instansi.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.asString)))
              .toList(),
          onChanged: (v) => controller.instansi.value = v ?? Instansi.EKL,
        ),
      ),
    );
  }

  static Widget _text(
    TextEditingController c, {
    required String label,
    bool required = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        readOnly: onTap != null,
        onTap: onTap,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  static Widget _number(TextEditingController c, {required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  static Future<void> _pickDate(
    BuildContext context,
    RenjaFormController controller,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  static Future<void> _pickTime(
    BuildContext context,
    RenjaFormController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      controller.timeCtrl.text = '$hh:$mm';
    }
  }

  static Widget _buildBengkelDropdown(RenjaFormController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
        () => controller.loadingBengkel.value
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: controller.selectedBengkelUuid.value,
                decoration: const InputDecoration(
                  labelText: 'Bengkel',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Pilih Bengkel'),
                items: controller.bengkelList.value
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.uuid,
                        child: Text(s.bengkelName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedBengkelUuid.value = value;
                },
              ),
      ),
    );
  }
}
