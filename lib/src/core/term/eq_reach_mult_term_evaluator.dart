// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQReachMultTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';

/// Returns the reach multiplier of an Equipment item.
class EQReachMultTermEvaluator extends BaseEQTermEvaluator
    implements TermEvaluator {
  EQReachMultTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  String evaluate(dynamic eq) {
    // Disabled if EQREACH control is active — caller should check.
    return eq.getSafeInt(IntegerKey.reachMult).toString();
  }

  @override
  bool isSourceDependant() => true;

  bool isStatic() => false;
}
