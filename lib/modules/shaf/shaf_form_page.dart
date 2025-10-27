import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/shaf_entity.dart';
import 'shaf_controller.dart';

class ShafFormPage extends StatefulWidget {
  const ShafFormPage({super.key, this.initial});
  final ShafEntity? initial;

  @override
  State<ShafFormPage> createState() => _ShafFormPageState();
}

class _ShafFormPageState extends State<ShafFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _bengkelName = TextEditingController();
  late String _bengkelType;
  String? _selectedAsiaUuid;
  String? _selectedCentralUuid;
  final _pu = TextEditingController(text: '0');
  final _a = TextEditingController(text: '0');
  final _b = TextEditingController(text: '0');
  final _c = TextEditingController(text: '0');
  final _d = TextEditingController(text: '0');

  List<ShafEntity> _asiaList = [];
  List<ShafEntity> _centralList = [];

  @override
  void initState() {
    super.initState();
    _bengkelType = 'rakit';
    final e = widget.initial;
    if (e != null) {
      _bengkelName.text = e.bengkelName;
      _bengkelType = e.bengkelType;
      _selectedAsiaUuid = e.asiaUuid;
      _selectedCentralUuid = e.centralUuid;
      _pu.text = e.totalPu.toString();
      _a.text = e.totalClassA.toString();
      _b.text = e.totalClassB.toString();
      _c.text = e.totalClassC.toString();
      _d.text = e.totalClassD.toString();
    }
    _loadAsiaList();
    _loadCentralList();
  }

  Future<void> _loadAsiaList() async {
    final c = Get.find<ShafController>();
    try {
      final response = await c.repo.getAll(bengkelType: 'asia');
      setState(() {
        _asiaList = response['data'] as List<ShafEntity>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load Asia list: $e')));
      }
    }
  }

  Future<void> _loadCentralList() async {
    final c = Get.find<ShafController>();
    try {
      final response = await c.repo.getAll(bengkelType: 'central');
      setState(() {
        _centralList = response['data'] as List<ShafEntity>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Central list: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _bengkelName.dispose();
    _pu.dispose();
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _d.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShafController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Tambah Bengkel' : 'Edit Bengkel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Bengkel Name
                TextFormField(
                  controller: _bengkelName,
                  decoration: const InputDecoration(
                    labelText: 'Bengkel Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                // Bengkel Type Dropdown
                DropdownButtonFormField<String>(
                  value: _bengkelType,
                  decoration: const InputDecoration(
                    labelText: 'Bengkel Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'rakit', child: Text('Rakit')),
                    DropdownMenuItem(value: 'asia', child: Text('Asia')),
                    DropdownMenuItem(value: 'central', child: Text('Central')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _bengkelType = value ?? 'rakit';
                      _selectedAsiaUuid = null;
                      _selectedCentralUuid = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Asia Dropdown (only for rakit type)
                if (_bengkelType == 'rakit') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedAsiaUuid,
                    decoration: const InputDecoration(
                      labelText: 'Select Asia Bengkel',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Asia Bengkel'),
                    items: _asiaList
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.uuid,
                            child: Text(s.bengkelName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAsiaUuid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                // Central Dropdown (for rakit or asia type)
                if (_bengkelType == 'rakit' || _bengkelType == 'asia') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCentralUuid,
                    decoration: const InputDecoration(
                      labelText: 'Select Central Bengkel',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Central Bengkel'),
                    items: _centralList
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.uuid,
                            child: Text(s.bengkelName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCentralUuid = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(_pu, 'Total PU')),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_a, 'Class A')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(_b, 'Class B')),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_c, 'Class C')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _numField(_d, 'Class D')),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (widget.initial == null) {
                          await c.create(
                            bengkelName: _bengkelName.text.trim(),
                            bengkelType: _bengkelType,
                            asiaUuid: _selectedAsiaUuid,
                            centralUuid: _selectedCentralUuid,
                            totalPu: int.tryParse(_pu.text) ?? 0,
                            totalClassA: int.tryParse(_a.text) ?? 0,
                            totalClassB: int.tryParse(_b.text) ?? 0,
                            totalClassC: int.tryParse(_c.text) ?? 0,
                            totalClassD: int.tryParse(_d.text) ?? 0,
                          );
                        } else {
                          await c.updateItem(
                            widget.initial!.copyWith(
                              bengkelName: _bengkelName.text.trim(),
                              bengkelType: _bengkelType,
                              asiaUuid: _selectedAsiaUuid,
                              centralUuid: _selectedCentralUuid,
                              totalPu: int.tryParse(_pu.text) ?? 0,
                              totalClassA: int.tryParse(_a.text) ?? 0,
                              totalClassB: int.tryParse(_b.text) ?? 0,
                              totalClassC: int.tryParse(_c.text) ?? 0,
                              totalClassD: int.tryParse(_d.text) ?? 0,
                            ),
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
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
