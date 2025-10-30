import '../../shared/enums/instansi.dart';
import '../../shared/enums/hijriah_month.dart';
import '../../shared/enums/shaf.dart';
import 'shaf_entity.dart';

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
  final String? shafUuid; // UUID of selected bengkel
  final ShafEntity? shafEntity; // Full bengkel entity with details
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
    this.shafUuid,
    this.shafEntity,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties for performance optimization
  // These are cached at the model level to avoid repeated DateTime.parse() calls

  /// Get the day name (Minggu, Senin, etc.) from the date string
  /// Cached to avoid repeated DateTime.parse() calls
  String get dayName {
    try {
      final dateTime = DateTime.parse(date);
      const days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
      ];
      return days[dateTime.weekday % 7];
    } catch (_) {
      return '';
    }
  }

  /// Get the formatted date string (e.g., "15 Jan 2024")
  /// Cached to avoid repeated DateTime.parse() calls
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (_) {
      return '';
    }
  }

  /// Check if the date has passed (is before today)
  /// Cached to avoid repeated DateTime.parse() calls
  bool get isDatePassed {
    try {
      final dateTime = DateTime.parse(date);
      return dateTime.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Get the status text for display
  /// Cached to avoid repeated string concatenation
  String get statusText {
    if (isTergelar == null) return '';
    if (isTergelar == true) return 'Tergelar';
    return 'Tidak - ${reasonTidakTergelar ?? 'No reason'}';
  }

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
    String? shafUuid,
    ShafEntity? shafEntity,
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
    shafUuid: shafUuid ?? this.shafUuid,
    shafEntity: shafEntity ?? this.shafEntity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Renja.fromMap(Map<String, dynamic> map) {
    final int? it = map['isTergelar'] as int?;

    // Handle shaf field - can be either String (old format) or Map (new format)
    String? sh;
    Map<String, dynamic>? shafMap;

    if (map['shaf'] is Map) {
      shafMap = map['shaf'] as Map<String, dynamic>;
    } else if (map['shaf'] is String) {
      sh = map['shaf'] as String;
    }

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
      shafUuid: map['shafUuid'] as String?,
      shafEntity: shafMap != null ? ShafEntity.fromMap(shafMap) : null,
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
    'shafUuid': shafUuid,
    'shafEntity': shafEntity?.toMap(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
