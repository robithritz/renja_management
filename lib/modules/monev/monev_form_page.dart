import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/monev.dart';
import '../../shared/enums/hijriah_month.dart';
import 'monev_controller.dart';
import '../../data/repositories/shaf_repository.dart';
import '../../data/models/shaf_entity.dart';

class MonevFormPage extends StatefulWidget {
  const MonevFormPage({super.key, this.initial});
  final Monev? initial;

  @override
  State<MonevFormPage> createState() => _MonevFormPageState();
}

class _MonevFormPageState extends State<MonevFormPage> {
  final _formKey = GlobalKey<FormState>();

  HijriahMonth _bulan = HijriahMonth.muharram;
  final _tahun = TextEditingController(text: '1447');
  int _week = 1;
  String? _selectedShafUuid;
  ShafEntity? _selectedShaf;
  List<ShafEntity> _shafList = [];

  final _malPu = TextEditingController(text: '0');
  final _malA = TextEditingController(text: '0');
  final _malB = TextEditingController(text: '0');
  final _malC = TextEditingController(text: '0');
  final _malD = TextEditingController(text: '0');
  final _nomMal = TextEditingController(text: '0');

  final _bnPu = TextEditingController(text: '0');
  final _bnA = TextEditingController(text: '0');
  final _bnB = TextEditingController(text: '0');
  final _bnC = TextEditingController(text: '0');
  final _bnD = TextEditingController(text: '0');

  final _newMember = TextEditingController(text: '0');
  final _kdpu = TextEditingController(text: '0');

  final _narrationMal = TextEditingController();
  final _narrationBn = TextEditingController();
  final _narrationDkw = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _bulan = e.bulanHijriah;
      _tahun.text = e.tahunHijriah.toString();
      _week = e.weekNumber;
      _selectedShafUuid = e.shafUuid;
      _malPu.text = e.activeMalPu.toString();
      _malA.text = e.activeMalClassA.toString();
      _malB.text = e.activeMalClassB.toString();
      _malC.text = e.activeMalClassC.toString();
      _malD.text = e.activeMalClassD.toString();
      _nomMal.text = e.nominalMal.toString();
      _bnPu.text = e.activeBnPu.toString();
      _bnA.text = e.activeBnClassA.toString();
      _bnB.text = e.activeBnClassB.toString();
      _bnC.text = e.activeBnClassC.toString();
      _bnD.text = e.activeBnClassD.toString();
      _newMember.text = e.totalNewMember.toString();
      _kdpu.text = e.totalKdpu.toString();
      _narrationMal.text = e.narrationMal ?? '';
      _narrationBn.text = e.narrationBn ?? '';
      _narrationDkw.text = e.narrationDkw ?? '';
    }
    _attachPctListeners();

    _loadShaf();
  }

  @override
  void dispose() {
    _tahun.dispose();

    _malPu.dispose();
    _malA.dispose();
    _malB.dispose();
    _malC.dispose();
    _malD.dispose();
    _nomMal.dispose();
    _bnPu.dispose();
    _bnA.dispose();
    _bnB.dispose();
    _bnC.dispose();
    _bnD.dispose();
    _newMember.dispose();
    _kdpu.dispose();
    _narrationMal.dispose();
    _narrationBn.dispose();
    _narrationDkw.dispose();

    super.dispose();
  }

  Future<void> _loadShaf() async {
    final repo = Get.isRegistered<ShafRepository>()
        ? Get.find<ShafRepository>()
        : Get.put(ShafRepository(), permanent: true);
    final list = await repo.getAll();
    if (!mounted) return;
    setState(() {
      _shafList = list;
      if (_selectedShafUuid != null) {
        _selectedShaf = _shafList.firstWhere(
          (s) => s.uuid == _selectedShafUuid,
          orElse: () => _shafList.isNotEmpty
              ? _shafList.first
              : ShafEntity(
                  uuid: '',
                  bengkelName: '',
                  bengkelType: 'rakit',
                  totalPu: 0,
                  totalClassA: 0,
                  totalClassB: 0,
                  totalClassC: 0,
                  totalClassD: 0,
                  createdAt: '',
                  updatedAt: '',
                ),
        );
        if (_selectedShaf!.uuid.isEmpty) _selectedShaf = null;
      }
    });
  }

  void _attachPctListeners() {
    for (final c in [
      _malPu,
      _malA,
      _malB,
      _malC,
      _malD,
      _bnPu,
      _bnA,
      _bnB,
      _bnC,
      _bnD,
      _newMember,
      _kdpu,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  String _fmtPct(int num, int? denom) {
    if (denom == null || denom <= 0) return '-';
    final v = (num / denom) * 100;
    return '${v.toStringAsFixed(1)}%';
  }

  int _val(TextEditingController c) => int.tryParse(c.text) ?? 0;

  Widget _numWithPct(TextEditingController c, String label, int? denom) {
    return Row(
      children: [
        Expanded(child: _numField(c, label)),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(_fmtPct(_val(c), denom), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MonevController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Tambah Monev' : 'Edit Monev'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Column(
                  children: [
                    _bulanDropdown(),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tahun,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Hijriah',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    _weekDropdown(),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedShafUuid,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Shaf',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Pilih Shaf'),
                  items: _shafList
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.uuid,
                          child: Text(s.bengkelName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedShafUuid = v;
                      _selectedShaf = _shafList.firstWhere(
                        (s) => s.uuid == v,
                        orElse: () => _shafList.isNotEmpty
                            ? _shafList.first
                            : ShafEntity(
                                uuid: '',
                                bengkelName: '',
                                bengkelType: 'rakit',
                                totalPu: 0,
                                totalClassA: 0,
                                totalClassB: 0,
                                totalClassC: 0,
                                totalClassD: 0,
                                createdAt: '',
                                updatedAt: '',
                              ),
                      );
                      if (_selectedShaf!.uuid.isEmpty) _selectedShaf = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('MAL'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _numWithPct(
                        _malPu,
                        'PU Aktif',
                        _selectedShaf?.totalPu,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numWithPct(
                        _malA,
                        'Kelas A',
                        _selectedShaf?.totalClassA,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _numWithPct(
                        _malB,
                        'Kelas B',
                        _selectedShaf?.totalClassB,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numWithPct(
                        _malC,
                        'Kelas C',
                        _selectedShaf?.totalClassC,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _numWithPct(
                        _malD,
                        'Kelas D',
                        _selectedShaf?.totalClassD,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _numField(_nomMal, 'Nominal (Rp)')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _narrationMal,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Narasi MAL',
                    hintText: 'Catatan atau narasi untuk MAL...',
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
                        _bnPu,
                        'PU Aktif',
                        _selectedShaf?.totalPu,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numWithPct(
                        _bnA,
                        'Kelas A',
                        _selectedShaf?.totalClassA,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _numWithPct(
                        _bnB,
                        'Kelas B',
                        _selectedShaf?.totalClassB,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numWithPct(
                        _bnC,
                        'Kelas C',
                        _selectedShaf?.totalClassC,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _numWithPct(
                        _bnD,
                        'Kelas D',
                        _selectedShaf?.totalClassD,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _narrationBn,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Narasi BN',
                    hintText: 'Catatan atau narasi untuk BN...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('DKW'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _numField(_kdpu, 'Total KDPU')),
                    const SizedBox(width: 6),
                    Expanded(child: _numField(_newMember, 'New Member')),
                    // const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _narrationDkw,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Narasi DKW',
                    hintText: 'Catatan atau narasi untuk DKW...',
                    border: OutlineInputBorder(),
                  ),
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
                            shafUuid: _selectedShafUuid,
                            bulanHijriah: _bulan,
                            tahunHijriah: int.tryParse(_tahun.text) ?? 0,
                            weekNumber: _week,
                            activeMalPu: int.tryParse(_malPu.text) ?? 0,
                            activeMalClassA: int.tryParse(_malA.text) ?? 0,
                            activeMalClassB: int.tryParse(_malB.text) ?? 0,
                            activeMalClassC: int.tryParse(_malC.text) ?? 0,
                            activeMalClassD: int.tryParse(_malD.text) ?? 0,
                            nominalMal: int.tryParse(_nomMal.text) ?? 0,
                            activeBnPu: int.tryParse(_bnPu.text) ?? 0,
                            activeBnClassA: int.tryParse(_bnA.text) ?? 0,
                            activeBnClassB: int.tryParse(_bnB.text) ?? 0,
                            activeBnClassC: int.tryParse(_bnC.text) ?? 0,
                            activeBnClassD: int.tryParse(_bnD.text) ?? 0,
                            totalNewMember: int.tryParse(_newMember.text) ?? 0,
                            totalKdpu: int.tryParse(_kdpu.text) ?? 0,
                            narrationMal: _narrationMal.text.trim().isEmpty
                                ? null
                                : _narrationMal.text.trim(),
                            narrationBn: _narrationBn.text.trim().isEmpty
                                ? null
                                : _narrationBn.text.trim(),
                            narrationDkw: _narrationDkw.text.trim().isEmpty
                                ? null
                                : _narrationDkw.text.trim(),
                          );
                        } else {
                          await c.updateItem(
                            widget.initial!.copyWith(
                              shafUuid: _selectedShafUuid,
                              bulanHijriah: _bulan,
                              tahunHijriah: int.tryParse(_tahun.text) ?? 0,
                              weekNumber: _week,
                              activeMalPu: int.tryParse(_malPu.text) ?? 0,
                              activeMalClassA: int.tryParse(_malA.text) ?? 0,
                              activeMalClassB: int.tryParse(_malB.text) ?? 0,
                              activeMalClassC: int.tryParse(_malC.text) ?? 0,
                              activeMalClassD: int.tryParse(_malD.text) ?? 0,
                              nominalMal: int.tryParse(_nomMal.text) ?? 0,
                              activeBnPu: int.tryParse(_bnPu.text) ?? 0,
                              activeBnClassA: int.tryParse(_bnA.text) ?? 0,
                              activeBnClassB: int.tryParse(_bnB.text) ?? 0,
                              activeBnClassC: int.tryParse(_bnC.text) ?? 0,
                              activeBnClassD: int.tryParse(_bnD.text) ?? 0,
                              totalNewMember:
                                  int.tryParse(_newMember.text) ?? 0,
                              totalKdpu: int.tryParse(_kdpu.text) ?? 0,
                              narrationMal: _narrationMal.text.trim().isEmpty
                                  ? null
                                  : _narrationMal.text.trim(),
                              narrationBn: _narrationBn.text.trim().isEmpty
                                  ? null
                                  : _narrationBn.text.trim(),
                              narrationDkw: _narrationDkw.text.trim().isEmpty
                                  ? null
                                  : _narrationDkw.text.trim(),
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

  Widget _bulanDropdown() {
    return DropdownButtonFormField<HijriahMonth>(
      value: _bulan,
      decoration: const InputDecoration(
        labelText: 'Bulan Hijriah',
        border: OutlineInputBorder(),
      ),
      items: HijriahMonth.values
          .map((e) => DropdownMenuItem(value: e, child: Text(e.asString)))
          .toList(),
      onChanged: (v) => setState(() => _bulan = v ?? _bulan),
    );
  }

  Widget _weekDropdown() {
    return DropdownButtonFormField<int>(
      value: _week,
      decoration: const InputDecoration(
        labelText: 'Pekan Ke-',
        border: OutlineInputBorder(),
      ),
      items: const [1, 2, 3, 4]
          .map((e) => DropdownMenuItem(value: e, child: Text('Pekan $e')))
          .toList(),
      onChanged: (v) => setState(() => _week = v ?? _week),
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
