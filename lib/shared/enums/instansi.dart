enum Instansi { EKL, DAKWAH, IKK, TRB, SYR, UP, SK, WK_SK }

extension InstansiX on Instansi {
  /// Get the enum name (for API/database storage)
  String get asString => name;

  /// Get the display name (for UI)
  String get displayName {
    switch (this) {
      case Instansi.EKL:
        return 'Kunci L';
      case Instansi.DAKWAH:
        return 'Kunci Duplikat';
      case Instansi.IKK:
        return 'Kunci Inggris';
      case Instansi.TRB:
        return 'Kunci T';
      case Instansi.SYR:
        return 'Kunci Sparepart';
      case Instansi.UP:
        return 'UP';
      case Instansi.SK:
        return 'Kasir';
      case Instansi.WK_SK:
        return 'Kasir 2';
    }
  }

  static Instansi fromString(String s) => Instansi.values.firstWhere(
    (e) => e.name.toLowerCase() == s.toLowerCase(),
    orElse: () => Instansi.EKL,
  );
}
