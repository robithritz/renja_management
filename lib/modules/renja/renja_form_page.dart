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

class RenjaFormPage extends StatefulWidget {
  const RenjaFormPage({super.key, this.existing});
  final Renja? existing;

  @override
  State<RenjaFormPage> createState() => _RenjaFormPageState();
}

class _RenjaFormPageState extends State<RenjaFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _dateCtrl = TextEditingController();
  HijriahMonth _bulanHijriah = HijriahMonth.muharram;
  final _tahunHijriahCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _kegiatanCtrl = TextEditingController();
  final _titikCtrl = TextEditingController();
  final _picCtrl = TextEditingController();
  final _sasaranCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _tujuanCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  Instansi _instansi = Instansi.EKL;

  String? _selectedBengkelUuid;
  List<ShafEntity> _bengkelList = [];
  bool _loadingBengkel = false;

  @override
  void initState() {
    super.initState();
    _loadBengkelList();
    final e = widget.existing;
    if (e != null) {
      _dateCtrl.text = e.date;
      _bulanHijriah = e.bulanHijriah;
      _tahunHijriahCtrl.text = e.tahunHijriah.toString();
      _dayCtrl.text = e.day.toString();
      _timeCtrl.text = e.time;
      _kegiatanCtrl.text = e.kegiatanDesc;
      _titikCtrl.text = e.titikDesc;
      _picCtrl.text = e.pic;
      _sasaranCtrl.text = e.sasaran;
      _targetCtrl.text = e.target;
      _tujuanCtrl.text = e.tujuan;
      _volumeCtrl.text = e.volume.toString();
      _costCtrl.text = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(e.cost);
      _instansi = e.instansi;
      _selectedBengkelUuid = e.shafUuid;
    }
  }

  Future<void> _loadBengkelList() async {
    setState(() => _loadingBengkel = true);
    try {
      final repo = ShafApiRepository();
      final response = await repo.getAll();
      setState(() {
        _bengkelList = response['data'] as List<ShafEntity>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bengkel list: $e')),
        );
      }
    } finally {
      setState(() => _loadingBengkel = false);
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _tahunHijriahCtrl.dispose();
    _dayCtrl.dispose();
    _timeCtrl.dispose();
    _kegiatanCtrl.dispose();
    _titikCtrl.dispose();
    _picCtrl.dispose();
    _sasaranCtrl.dispose();
    _targetCtrl.dispose();
    _tujuanCtrl.dispose();
    _volumeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RenjaController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Renja' : 'Edit Renja'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildBengkelDropdown(),
              _text(_kegiatanCtrl, label: 'Kegiatan (desc)', required: true),
              _text(
                _dateCtrl,
                label: 'Date (YYYY-MM-DD)',
                required: true,
                onTap: _pickDate,
              ),
              Row(
                children: [
                  Expanded(child: _dropdownBulanHijriah()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _number(_tahunHijriahCtrl, label: 'Tahun Hijriah'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _number(_dayCtrl, label: 'Day (1-31)')),
                ],
              ),
              _text(_timeCtrl, label: 'Time (HH:mm)', onTap: _pickTime),
              _text(_titikCtrl, label: 'Titik (desc)'),
              _text(_picCtrl, label: 'PIC'),
              _text(_sasaranCtrl, label: 'Sasaran'),
              _text(_targetCtrl, label: 'Target'),
              _text(_tujuanCtrl, label: 'Tujuan'),
              _number(_volumeCtrl, label: 'Volume'),
              _dropdownInstansi(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _costCtrl,
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
                  if (!_formKey.currentState!.validate()) return;
                  if (widget.existing == null) {
                    await c.create(
                      date: _dateCtrl.text.trim(),
                      bulanHijriah: _bulanHijriah,
                      tahunHijriah:
                          int.tryParse(_tahunHijriahCtrl.text.trim()) ?? 0,
                      day: int.tryParse(_dayCtrl.text.trim()) ?? 1,
                      time: _timeCtrl.text.trim(),
                      kegiatanDesc: _kegiatanCtrl.text.trim(),
                      titikDesc: _titikCtrl.text.trim(),
                      pic: _picCtrl.text.trim(),
                      sasaran: _sasaranCtrl.text.trim(),
                      target: _targetCtrl.text.trim(),
                      tujuan: _tujuanCtrl.text.trim(),
                      volume: double.tryParse(_volumeCtrl.text.trim()) ?? 0,
                      instansi: _instansi,
                      cost: RupiahInputFormatter.parseToInt(_costCtrl.text),
                      shafUuid: _selectedBengkelUuid,
                    );
                  } else {
                    final e = widget.existing!;
                    await c.updateItem(
                      e.copyWith(
                        date: _dateCtrl.text.trim(),
                        bulanHijriah: _bulanHijriah,
                        tahunHijriah:
                            int.tryParse(_tahunHijriahCtrl.text.trim()) ??
                            e.tahunHijriah,
                        day: int.tryParse(_dayCtrl.text.trim()) ?? e.day,
                        time: _timeCtrl.text.trim(),
                        kegiatanDesc: _kegiatanCtrl.text.trim(),
                        titikDesc: _titikCtrl.text.trim(),
                        pic: _picCtrl.text.trim(),
                        sasaran: _sasaranCtrl.text.trim(),
                        target: _targetCtrl.text.trim(),
                        tujuan: _tujuanCtrl.text.trim(),
                        volume:
                            double.tryParse(_volumeCtrl.text.trim()) ??
                            e.volume,
                        instansi: _instansi,
                        cost: RupiahInputFormatter.parseToInt(_costCtrl.text),
                        shafUuid: _selectedBengkelUuid,
                      ),
                    );
                  }
                  if (mounted) Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownBulanHijriah() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<HijriahMonth>(
        value: _bulanHijriah,
        decoration: const InputDecoration(
          labelText: 'Bulan Hijriah',
          border: OutlineInputBorder(),
        ),
        items: HijriahMonth.values
            .map((m) => DropdownMenuItem(value: m, child: Text(m.asString)))
            .toList(),
        onChanged: (v) {
          if (v != null) setState(() => _bulanHijriah = v);
        },
      ),
    );
  }

  Widget _dropdownInstansi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<Instansi>(
        value: _instansi,
        decoration: const InputDecoration(
          labelText: 'Instansi',
          border: OutlineInputBorder(),
        ),
        items: Instansi.values
            .map((e) => DropdownMenuItem(value: e, child: Text(e.asString)))
            .toList(),
        onChanged: (v) => setState(() => _instansi = v ?? Instansi.EKL),
      ),
    );
  }

  Widget _text(
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

  Widget _number(TextEditingController c, {required String label}) {
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      _timeCtrl.text = '$hh:$mm';
    }
  }

  Widget _buildBengkelDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _loadingBengkel
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<String>(
              value: _selectedBengkelUuid,
              decoration: const InputDecoration(
                labelText: 'Bengkel',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih Bengkel'),
              items: _bengkelList
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.uuid,
                      child: Text(s.bengkelName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBengkelUuid = value;
                });
              },
            ),
    );
  }
}
