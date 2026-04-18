// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermEvaluator

/// Interface for objects that can evaluate a single "term" in a formula
/// for a PlayerCharacter or Equipment.
abstract interface class TermEvaluator {
  String evaluate(dynamic pc);
  String evaluateWithSpell(dynamic pc, dynamic aSpell);
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc);
  double? resolve(dynamic pc);
  double? resolveWithSpell(dynamic pc, dynamic aSpell);
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc);
  bool isSourceDependant();
}
