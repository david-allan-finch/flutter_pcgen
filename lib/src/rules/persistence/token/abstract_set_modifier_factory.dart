// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractSetModifierFactory

import 'package:flutter_pcgen/src/rules/persistence/token/modifier_factory.dart';

/// A [ModifierFactory] / BasicCalculation that always returns the [argument]
/// value, ignoring [previousValue].
///
/// This is the "SET" modifier: regardless of whatever value the variable
/// currently holds, applying this modifier sets it to the specified value.
///
/// [T] is the format of the object being modified (e.g. num, String).
///
/// TODO: The following Java types have not yet been ported:
///   - FormatManager<T>  (use dynamic)
///   - FormulaModifier<T> (use dynamic)
///   - NEPCalculation<T>, ProcessCalculation<T>, CalculationModifier<T>
///   - BasicCalculation<T> interface
///
/// Mirrors Java: AbstractSetModifierFactory<T> implements ModifierFactory<T>, BasicCalculation<T>
abstract class AbstractSetModifierFactory<T> implements ModifierFactory<T> {
  // ---------------------------------------------------------------------------
  // BasicCalculation<T>
  // ---------------------------------------------------------------------------

  /// The "SET" calculation: returns [argument], ignoring [previousValue].
  T process(T previousValue, T argument) => argument;

  /// Priority for modifier ordering – SET has inherent priority 0.
  int getInherentPriority() => 0;

  // ---------------------------------------------------------------------------
  // ModifierFactory<T>
  // ---------------------------------------------------------------------------

  @override
  String getIdentification() => 'SET';

  /// Returns a [FormulaModifier] that evaluates the [instructions] string with
  /// [formatManager] and sets the variable to the resulting value.
  ///
  /// For fixed (non-formula) values, [formatManager.convert] must succeed.
  /// If it fails (null result) an [ArgumentError] is thrown.
  ///
  /// TODO: implement once FormatManager + CalculationModifier are ported.
  @override
  dynamic getFixedModifier(dynamic formatManager, String instructions) {
    // Java logic:
    //   T n = formatManager.convert(instructions);
    //   if (n == null) throw new IllegalArgumentException(…);
    //   NEPCalculation<T> calc = new ProcessCalculation<>(n, this, formatManager);
    //   return new CalculationModifier<>(calc, formatManager);
    throw UnimplementedError(
        'AbstractSetModifierFactory.getFixedModifier: '
        'requires FormatManager + CalculationModifier infrastructure');
  }

  /// Returns a [FormulaModifier] by delegating to [getFixedModifier].
  ///
  /// Validates that [formatManager] manages a type compatible with
  /// [getVariableFormat] before delegating.
  ///
  /// TODO: implement once FormatManager + CalculationModifier are ported.
  @override
  dynamic getModifier(String instructions, dynamic formatManager) {
    // Java logic:
    //   if (!getVariableFormat().isAssignableFrom(formatManager.getManagedClass()))
    //       throw new IllegalArgumentException(…);
    //   T n = formatManager.convert(instructions);
    //   if (n == null) throw new IllegalArgumentException(…);
    //   NEPCalculation<T> calc = new ProcessCalculation<>(n, this, formatManager);
    //   return new CalculationModifier<>(calc, formatManager);
    throw UnimplementedError(
        'AbstractSetModifierFactory.getModifier: '
        'requires FormatManager + CalculationModifier infrastructure');
  }
}
