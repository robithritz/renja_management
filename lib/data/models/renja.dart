import '../../shared/enums/instansi.dart';

class Renja {
  final String uuid;
  final String date; // ISO YYYY-MM-DD
  final String bulanHijriah; // e.g., Muharram (free text)
  final int tahunHijriah;
  final int day; // 1-31
  final String time; // HH:mm
  final String kegiatanDesc;
  final String titikDesc;
  final String pic;
  final String sasaran;
  final String target;
  final String tujuan;
  final double volume;
  final Instansi instansi;
  final int cost; // store in smallest currency unit (e.g., rupiah)
  final String createdAt; // ISO
  final String updatedAt; // ISO

  const Renja({
    required this.uuid,
    required this.date,
    required this.bulanHijriah,
    required this.tahunHijriah,
    required this.day,
    required this.time,
    required this.kegiatanDesc,
    required this.titikDesc,
    required this.pic,
    required this.sasaran,
    required this.target,
    required this.tujuan,
    required this.volume,
    required this.instansi,
    required this.cost,
    required this.createdAt,
    required this.updatedAt,
  });

  Renja copyWith({
    String? uuid,
    String? date,
    String? bulanHijriah,
    int? tahunHijriah,
    int? day,
    String? time,
    String? kegiatanDesc,
    String? titikDesc,
    String? pic,
    String? sasaran,
    String? target,
    String? tujuan,
    double? volume,
    Instansi? instansi,
    int? cost,
    String? createdAt,
    String? updatedAt,
  }) => Renja(
    uuid: uuid ?? this.uuid,
    date: date ?? this.date,
    bulanHijriah: bulanHijriah ?? this.bulanHijriah,
    tahunHijriah: tahunHijriah ?? this.tahunHijriah,
    day: day ?? this.day,
    time: time ?? this.time,
    kegiatanDesc: kegiatanDesc ?? this.kegiatanDesc,
    titikDesc: titikDesc ?? this.titikDesc,
    pic: pic ?? this.pic,
    sasaran: sasaran ?? this.sasaran,
    target: target ?? this.target,
    tujuan: tujuan ?? this.tujuan,
    volume: volume ?? this.volume,
    instansi: instansi ?? this.instansi,
    cost: cost ?? this.cost,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Renja.fromMap(Map<String, dynamic> map) {
    return Renja(
      uuid: map['uuid'] as String,
      date: map['date'] as String,
      bulanHijriah: map['bulan_hijriah'] as String,
      tahunHijriah: map['tahun_hijriah'] as int,
      day: map['day'] as int,
      time: map['time'] as String,
      kegiatanDesc: map['kegiatan_desc'] as String,
      titikDesc: map['titik_desc'] as String,
      pic: map['pic'] as String,
      sasaran: map['sasaran'] as String,
      target: map['target'] as String,
      tujuan: map['tujuan'] as String,
      volume: (map['volume'] as num).toDouble(),
      instansi: InstansiX.fromString(map['instansi'] as String),
      cost: map['cost'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'date': date,
    'bulan_hijriah': bulanHijriah,
    'tahun_hijriah': tahunHijriah,
    'day': day,
    'time': time,
    'kegiatan_desc': kegiatanDesc,
    'titik_desc': titikDesc,
    'pic': pic,
    'sasaran': sasaran,
    'target': target,
    'tujuan': tujuan,
    'volume': volume,
    'instansi': instansi.asString,
    'cost': cost,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
