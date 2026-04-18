// JEPFormula is a variable-value Formula evaluated through the JEP formula
// evaluation system.  It delegates resolution to the PlayerCharacter.
class JEPFormula {
  final String _formula;

  // Package-private constructor; use FormulaFactory to create instances.
  JEPFormula(this._formula);

  @override
  String toString() => _formula;

  @override
  int get hashCode => _formula.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is JEPFormula && obj._formula == _formula;

  /// Resolves the formula in the context of the given PlayerCharacter.
  num resolve(dynamic character, String source) {
    return character.getVariableValue(_formula, source) as num;
  }

  /// Returns false: a JEPFormula depends on the character state.
  bool isStatic() => false;

  /// Resolves the formula given an Equipment context.
  num resolveEquipment(dynamic equipment, bool primary, dynamic pc, String source) {
    return equipment.getVariableValue(_formula, source, primary, pc) as num;
  }

  bool isValid() => true;

  num resolveStatic() {
    throw UnsupportedError('Formula is not static');
  }
}
