enum Instansi { EKL, DAKWAH, IKK, TRB, SYR, UP, SK, WK_SK }

extension InstansiX on Instansi {
  String get asString => name;
  static Instansi fromString(String s) => Instansi.values.firstWhere(
    (e) => e.name.toLowerCase() == s.toLowerCase(),
    orElse: () => Instansi.EKL,
  );
}
