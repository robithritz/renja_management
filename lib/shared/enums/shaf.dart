enum Shaf { AC, CB }

extension ShafX on Shaf {
  String get asString => name; // 'AC' or 'CB'

  static Shaf fromString(String v) {
    switch (v) {
      case 'AC':
      case 'AC 1':
        return Shaf.AC;
      case 'CB':
        return Shaf.CB;
      default:
        throw ArgumentError('Unknown Shaf value: $v');
    }
  }
}
