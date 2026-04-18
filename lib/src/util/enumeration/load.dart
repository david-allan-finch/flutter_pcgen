/// Encumbrance load categories.
///
/// The [calcEncumberedMove] method preserves the original game movement
/// penalty logic. Display properties (font, color) are intentionally omitted
/// here — they belong in the UI layer.
enum Load {
  light,
  medium,
  heavy,
  overload;

  static Load? getLoadType(String val) {
    return Load.values.firstWhere(
      (l) => l.name.toUpperCase() == val.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown Load value: $val'),
    );
  }

  Load max(Load other) => index >= other.index ? this : other;

  double calcEncumberedMove(double unencumberedMove) {
    return switch (this) {
      Load.light => unencumberedMove,
      Load.medium || Load.heavy => _mediumHeavyMove(unencumberedMove),
      Load.overload => 0.0,
    };
  }

  static double _mediumHeavyMove(double unencumberedMove) {
    if ((unencumberedMove - 5).abs() < 1e-9 ||
        (unencumberedMove - 10).abs() < 1e-9) {
      return 5.0;
    }
    return (unencumberedMove / 15).floorToDouble() * 10 +
        (unencumberedMove.toInt() % 15);
  }
}
