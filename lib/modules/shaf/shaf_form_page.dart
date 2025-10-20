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
  final _asia = TextEditingController();
  final _rakit = TextEditingController();
  final _pu = TextEditingController(text: '0');
  final _a = TextEditingController(text: '0');
  final _b = TextEditingController(text: '0');
  final _c = TextEditingController(text: '0');
  final _d = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _asia.text = e.asiaName;
      _rakit.text = e.rakitName;
      _pu.text = e.totalPu.toString();
      _a.text = e.totalClassA.toString();
      _b.text = e.totalClassB.toString();
      _c.text = e.totalClassC.toString();
      _d.text = e.totalClassD.toString();
    }
  }

  @override
  void dispose() {
    _asia.dispose();
    _rakit.dispose();
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
      appBar: AppBar(title: Text(widget.initial == null ? 'Tambah Shaf' : 'Edit Shaf')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _asia,
                  decoration: const InputDecoration(labelText: 'Asia Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rakit,
                  decoration: const InputDecoration(labelText: 'Rakit Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_pu, 'Total PU')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_a, 'Class A')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_b, 'Class B')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_c, 'Class C')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_d, 'Class D')),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox.shrink()),
                ]),
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
                            asiaName: _asia.text.trim(),
                            rakitName: _rakit.text.trim(),
                            totalPu: int.tryParse(_pu.text) ?? 0,
                            totalClassA: int.tryParse(_a.text) ?? 0,
                            totalClassB: int.tryParse(_b.text) ?? 0,
                            totalClassC: int.tryParse(_c.text) ?? 0,
                            totalClassD: int.tryParse(_d.text) ?? 0,
                          );
                        } else {
                          await c.updateItem(
                            widget.initial!.copyWith(
                              asiaName: _asia.text.trim(),
                              rakitName: _rakit.text.trim(),
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
                )
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
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}

