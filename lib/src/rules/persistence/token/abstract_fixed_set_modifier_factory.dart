// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.token.AbstractFixedSetModifierFactory

import 'package:flutter_pcgen/src/rules/persistence/token/abstract_set_modifier_factory.dart';

/// A [AbstractSetModifierFactory] for format types that are *fixed* (i.e. fully
/// determined by the instruction string without reference to other objects).
///
/// Examples of fixed formats: Number, String.
/// Non-fixed examples (excluded from this class): Skill, Language, etc.
///
/// The only override is [getModifier]: it validates that [formatManager]
/// manages a type compatible with [getVariableFormat], then delegates to
/// [getFixedModifier] (inherited from [AbstractSetModifierFactory]).
///
/// [T] is the format of the object being modified.
///
/// TODO: The following Java types have not yet been ported:
///   - FormatManager<T>  (use dynamic)
///   - FormulaModifier<T> (use dynamic)
///
/// Mirrors Java: AbstractFixedSetModifierFactory<T> extends AbstractSetModifierFactory<T>
abstract class AbstractFixedSetModifierFactory<T>
    extends AbstractSetModifierFactory<T> {
  /// Returns a [FormulaModifier] by forwarding to [getFixedModifier].
  ///
  /// Validates first that [formatManager] manages a type that is assignable to
  /// [getVariableFormat]; throws [ArgumentError] otherwise.
  ///
  /// TODO: implement once FormatManager infrastructure is ported.
  @override
  dynamic getModifier(String instructions, dynamic formatManager) {
    // Java logic:
    //   if (!getVariableFormat().isAssignableFrom(formatManager.getManagedClass()))
    //       throw new IllegalArgumentException(
    //           "FormatManager must manage " + getVariableFormat().getName());
    //   return getFixedModifier(formatManager, instructions);
    throw UnimplementedError(
        'AbstractFixedSetModifierFactory.getModifier: '
        'requires FormatManager infrastructure');
  }
}
