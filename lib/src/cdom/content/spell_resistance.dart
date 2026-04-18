// Represents spell resistance (SR value formula).
class SpellResistance {
  final String _formula;

  const SpellResistance(this._formula);

  String getFormula() => _formula;

  @override
  String toString() => _formula;
}
