enum Instansi { EKL, DAKWAH, IKK, TRB, UP }

extension InstansiX on Instansi {
  String get asString => name;
  static Instansi fromString(String s) => Instansi.values.firstWhere(
        (e) => e.name.toLowerCase() == s.toLowerCase(),
        orElse: () => Instansi.EKL,
      );
}

