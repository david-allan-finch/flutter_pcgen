// Evaluation context passed to the FTL engine.
// Provides variable storage and the PCGen token API (pcstring/pcvar/pcboolean).

abstract class FtlContext {
  final Map<String, dynamic> vars = {};

  /// Evaluate a PCGen export string token (e.g. "NAME", "STAT.0.SCORE").
  String pcstring(String token);

  /// Evaluate a PCGen numeric variable (e.g. "STR", "COUNT[CLASSES]").
  double pcvar(String token);

  /// Evaluate a PCGen boolean (e.g. "WEAPON.0.ISRANGED").
  bool pcboolean(String token);
}
