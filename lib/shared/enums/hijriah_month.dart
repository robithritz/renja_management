enum HijriahMonth {
  muharram,
  shafar,
  rabiul_awwal,
  rabiul_akhir,
  jumadil_awwal,
  jumadil_akhir,
  rajab,
  syaban,
  ramadhan,
  syawal,
  dzulqaidah,
  dzulhijjah,
}

extension HijriahMonthX on HijriahMonth {
  String get asString {
    switch (this) {
      case HijriahMonth.muharram:
        return 'Muharram';
      case HijriahMonth.shafar:
        return 'Shafar';
      case HijriahMonth.rabiul_awwal:
        return 'Rabiul Awwal';
      case HijriahMonth.rabiul_akhir:
        return 'Rabiul Akhir';
      case HijriahMonth.jumadil_awwal:
        return 'Jumadil Awwal';
      case HijriahMonth.jumadil_akhir:
        return 'Jumadil Akhir';
      case HijriahMonth.rajab:
        return 'Rajab';
      case HijriahMonth.syaban:
        return 'Syaban';
      case HijriahMonth.ramadhan:
        return 'Ramadhan';
      case HijriahMonth.syawal:
        return 'Syawal';
      case HijriahMonth.dzulqaidah:
        return 'Dzulqoidah';
      case HijriahMonth.dzulhijjah:
        return 'Dzulhijjah';
    }
  }

  static HijriahMonth fromDb(String value) {
    // Accept either enum name or human label (case-insensitive, underscores/spaces tolerant)
    final v = value.trim().toLowerCase().replaceAll(' ', '_');
    for (final m in HijriahMonth.values) {
      if (m.name == v) return m;
      if (m.asString.toLowerCase().replaceAll(' ', '_') == v) return m;
    }
    // default fallback
    return HijriahMonth.muharram;
  }
}

