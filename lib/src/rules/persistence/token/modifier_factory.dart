/// A ModifierFactory builds Modifier objects for formula evaluation.
abstract interface class ModifierFactory<T> {
  /// Returns a string identifying the type of modification (e.g. "ADD").
  String getIdentification();

  /// Returns the variable format (Type) this factory can modify.
  Type getVariableFormat();

  /// Returns a FormulaModifier for the given instructions and format manager.
  dynamic getModifier(String instructions, dynamic formatManager);

  /// Returns a fixed (non-calculated) FormulaModifier for the given instructions.
  dynamic getFixedModifier(dynamic formatManager, String instructions);
}
