// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractNumberModifierFactory

import 'modifier_factory.dart';

/// A [ModifierFactory] / BasicCalculation for numeric variable types.
///
/// [getModifier] first attempts a fixed parse (via [getFixedModifier]); if the
/// instruction string is not a plain number it wraps it in a
/// [FormulaCalculation] so it is evaluated at runtime.
///
/// [T] is the numeric format of the object being modified (e.g. num).
///
/// TODO: The following Java types have not yet been ported:
///   - FormatManager<T>  (use dynamic)
///   - FormulaModifier<T> (use dynamic)
///   - NEPFormula<T>, FormulaFactory.getNEPFormulaFor
///   - NEPCalculation<T>, FormulaCalculation<T>, ProcessCalculation<T>
///   - CalculationModifier<T>
///   - BasicCalculation<T> interface
///
/// Mirrors Java: AbstractNumberModifierFactory<T>
///   implements ModifierFactory<T>, BasicCalculation<T>
abstract class AbstractNumberModifierFactory<T> implements ModifierFactory<T> {
  // ---------------------------------------------------------------------------
  // ModifierFactory<T>
  // ---------------------------------------------------------------------------

  /// Returns a [FormulaModifier].
  ///
  /// Tries a fixed parse first; if the instruction is not a literal number it
  /// falls back to a formula-based modifier.
  ///
  /// TODO: implement once FormulaFactory + CalculationModifier are ported.
  @override
  dynamic getModifier(String instructions, dynamic formatManager) {
    // Java logic:
    //   try {
    //     return getFixedModifier(formatManager, instructions);
    //   } catch (NumberFormatException e) {
    //     NEPFormula<T> f = FormulaFactory.getNEPFormulaFor(formatManager, instructions);
    //     NEPCalculation<T> calc = new FormulaCalculation<>(f, this);
    //     return new CalculationModifier<>(calc, formatManager);
    //   }
    throw UnimplementedError(
        'AbstractNumberModifierFactory.getModifier: '
        'requires FormulaFactory + CalculationModifier infrastructure');
  }

  /// Returns a fixed [FormulaModifier] by converting [instructions] via
  /// [formatManager].
  ///
  /// Throws [FormatException] (mirrors Java's NumberFormatException) if the
  /// instruction is not a parseable literal.
  ///
  /// TODO: implement once FormatManager + CalculationModifier are ported.
  @override
  dynamic getFixedModifier(dynamic formatManager, String instructions) {
    // Java logic:
    //   T n = formatManager.convert(instructions);  // may throw NumberFormatException
    //   NEPCalculation<T> calc = new ProcessCalculation<>(n, this, formatManager);
    //   return new CalculationModifier<>(calc, formatManager);
    throw UnimplementedError(
        'AbstractNumberModifierFactory.getFixedModifier: '
        'requires FormatManager + CalculationModifier infrastructure');
  }
}
