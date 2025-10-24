import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';
import '../../shared/enums/shaf.dart';

class Renja {
  final String uuid;
  final String date; // ISO YYYY-MM-DD
  final HijriahMonth bulanHijriah;
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
  final bool? isTergelar; // null = belum ditandai, true/false = status
  final String? reasonTidakTergelar; // required when isTergelar == false
  final Shaf? shaf; // AC/CB, nullable for existing rows
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
    this.isTergelar,
    this.reasonTidakTergelar,
    this.shaf,
    required this.createdAt,
    required this.updatedAt,
  });

  Renja copyWith({
    String? uuid,
    String? date,
    HijriahMonth? bulanHijriah,
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
    bool? isTergelar,
    String? reasonTidakTergelar,
    Shaf? shaf,
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
    isTergelar: isTergelar ?? this.isTergelar,
    reasonTidakTergelar: reasonTidakTergelar ?? this.reasonTidakTergelar,
    shaf: shaf ?? this.shaf,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Renja.fromMap(Map<String, dynamic> map) {
    final int? it = map['isTergelar'] as int?;
    final String? sh = map['shaf'] as String?;
    return Renja(
      uuid: map['uuid'] as String,
      date: map['date'] as String,
      bulanHijriah: HijriahMonthX.fromDb(map['bulanHijriah'] as String),
      tahunHijriah: map['tahunHijriah'] as int,
      day: map['day'] as int,
      time: map['time'] as String,
      kegiatanDesc: map['kegiatanDesc'] as String,
      titikDesc: map['titikDesc'] as String,
      pic: map['pic'] as String,
      sasaran: map['sasaran'] as String,
      target: map['target'] as String,
      tujuan: map['tujuan'] as String,
      volume: int.parse(map['volume'] as String).toDouble(),
      instansi: InstansiX.fromString(map['instansi'] as String),
      cost: map['cost'] as int,
      isTergelar: it == null ? null : (it == 1),
      reasonTidakTergelar: map['reasonTidakTergelar'] as String?,
      shaf: sh != null && sh.isNotEmpty ? ShafX.fromString(sh) : null,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'date': date,
    'bulanHijriah': bulanHijriah.name,
    'tahunHijriah': tahunHijriah,
    'day': day,
    'time': time,
    'kegiatanDesc': kegiatanDesc,
    'titikDesc': titikDesc,
    'pic': pic,
    'sasaran': sasaran,
    'target': target,
    'tujuan': tujuan,
    'volume': volume,
    'instansi': instansi.asString,
    'cost': cost,
    'isTergelar': isTergelar == null ? null : (isTergelar! ? 1 : 0),
    'reasonTidakTergelar': reasonTidakTergelar,
    'shaf': shaf?.asString,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
