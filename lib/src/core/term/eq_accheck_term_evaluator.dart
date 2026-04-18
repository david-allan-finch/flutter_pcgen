// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQACCheckTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class EQACCheckTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQACCheckTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // IntegerKey.AC_CHECK — deprecated when EQACCHECK CodeControl is used
    return (eq.getSafe('AC_CHECK') as num? ?? 0).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
