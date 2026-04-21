// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQSpellFailureTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';

/// Returns the arcane spell failure chance of an Equipment item.
class EQSpellFailureTermEvaluator extends BaseEQTermEvaluator
    implements TermEvaluator {
  EQSpellFailureTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  String evaluate(dynamic eq) {
    // Logs a warning if EQSPELLFAILURE control is active — caller should check.
    return eq.getSafeObject(ObjectKey.getConstant('SPELL_FAILURE')).toString();
  }

  @override
  bool isSourceDependant() => false;

  bool isStatic() => false;
}
