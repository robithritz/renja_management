import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/shaf_entity.dart';
import 'shaf_controller.dart';

// GetX Controller for Shaf Form
class ShafFormController extends GetxController {
  final ShafEntity? initial;
  ShafFormController({this.initial});

  final formKey = GlobalKey<FormState>();
  final bengkelName = TextEditingController();
  final bengkelType = Rx<String>('rakit');
  final selectedAsiaUuid = Rxn<String>();
  final selectedCentralUuid = Rxn<String>();
  final pu = TextEditingController(text: '0');
  final a = TextEditingController(text: '0');
  final b = TextEditingController(text: '0');
  final c = TextEditingController(text: '0');
  final d = TextEditingController(text: '0');

  final asiaList = Rx<List<ShafEntity>>([]);
  final centralList = Rx<List<ShafEntity>>([]);

  @override
  void onInit() {
    super.onInit();
    _initializeFormData();
    _loadAsiaList();
    _loadCentralList();
  }

  void _initializeFormData() {
    final e = initial;
    if (e != null) {
      bengkelName.text = e.bengkelName;
      bengkelType.value = e.bengkelType;
      selectedAsiaUuid.value = e.asiaUuid;
      selectedCentralUuid.value = e.centralUuid;
      pu.text = e.totalPu.toString();
      a.text = e.totalClassA.toString();
      b.text = e.totalClassB.toString();
      c.text = e.totalClassC.toString();
      d.text = e.totalClassD.toString();
    }
  }

  Future<void> _loadAsiaList() async {
    final c = Get.find<ShafController>();
    try {
      final response = await c.repo.getAll(bengkelType: 'asia');
      asiaList.value = response['data'] as List<ShafEntity>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Asia list: $e');
    }
  }

  Future<void> _loadCentralList() async {
    final c = Get.find<ShafController>();
    try {
      final response = await c.repo.getAll(bengkelType: 'central');
      centralList.value = response['data'] as List<ShafEntity>;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Central list: $e');
    }
  }

  @override
  void onClose() {
    bengkelName.dispose();
    pu.dispose();
    a.dispose();
    b.dispose();
    c.dispose();
    d.dispose();
    super.onClose();
  }
}

class ShafFormPage extends StatelessWidget {
  const ShafFormPage({super.key, this.initial});
  final ShafEntity? initial;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShafFormController(initial: initial));
    final c = Get.find<ShafController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(initial == null ? 'Tambah Bengkel' : 'Edit Bengkel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Bengkel Name
                TextFormField(
                  controller: controller.bengkelName,
                  decoration: const InputDecoration(
                    labelText: 'Bengkel Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                // Bengkel Type Dropdown
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.bengkelType.value,
                    decoration: const InputDecoration(
                      labelText: 'Bengkel Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'rakit', child: Text('Rakit')),
                      DropdownMenuItem(value: 'asia', child: Text('Asia')),
                      DropdownMenuItem(
                        value: 'central',
                        child: Text('Central'),
                      ),
                    ],
                    onChanged: (value) {
                      controller.bengkelType.value = value ?? 'rakit';
                      controller.selectedAsiaUuid.value = null;
                      controller.selectedCentralUuid.value = null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Asia Dropdown (only for rakit type)
                Obx(
                  () => controller.bengkelType.value == 'rakit'
                      ? Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: controller.selectedAsiaUuid.value,
                              decoration: const InputDecoration(
                                labelText: 'Select Asia Bengkel',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Pilih Asia Bengkel'),
                              items: controller.asiaList.value
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.uuid,
                                      child: Text(s.bengkelName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                controller.selectedAsiaUuid.value = value;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                // Central Dropdown (for rakit or asia type)
                Obx(
                  () =>
                      (controller.bengkelType.value == 'rakit' ||
                          controller.bengkelType.value == 'asia')
                      ? Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: controller.selectedCentralUuid.value,
                              decoration: const InputDecoration(
                                labelText: 'Select Central Bengkel',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Pilih Central Bengkel'),
                              items: controller.centralList.value
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.uuid,
                                      child: Text(s.bengkelName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                controller.selectedCentralUuid.value = value;
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(controller.pu, 'Total PU')),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(controller.a, 'Class A')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(controller.b, 'Class B')),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(controller.c, 'Class C')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(controller.d, 'Class D')),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
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
                        if (!controller.formKey.currentState!.validate()) {
                          return;
                        }
                        if (initial == null) {
                          await c.create(
                            bengkelName: controller.bengkelName.text.trim(),
                            bengkelType: controller.bengkelType.value,
                            asiaUuid: controller.selectedAsiaUuid.value,
                            centralUuid: controller.selectedCentralUuid.value,
                            totalPu: int.tryParse(controller.pu.text) ?? 0,
                            totalClassA: int.tryParse(controller.a.text) ?? 0,
                            totalClassB: int.tryParse(controller.b.text) ?? 0,
                            totalClassC: int.tryParse(controller.c.text) ?? 0,
                            totalClassD: int.tryParse(controller.d.text) ?? 0,
                          );
                        } else {
                          await c.updateItem(
                            initial!.copyWith(
                              bengkelName: controller.bengkelName.text.trim(),
                              bengkelType: controller.bengkelType.value,
                              asiaUuid: controller.selectedAsiaUuid.value,
                              centralUuid: controller.selectedCentralUuid.value,
                              totalPu: int.tryParse(controller.pu.text) ?? 0,
                              totalClassA: int.tryParse(controller.a.text) ?? 0,
                              totalClassB: int.tryParse(controller.b.text) ?? 0,
                              totalClassC: int.tryParse(controller.c.text) ?? 0,
                              totalClassD: int.tryParse(controller.d.text) ?? 0,
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
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
