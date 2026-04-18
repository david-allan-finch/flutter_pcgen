// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQHandsTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class EQHandsTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQHandsTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // IntegerKey.SLOTS
    return (eq.getSafe('SLOTS') as num? ?? 0).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
