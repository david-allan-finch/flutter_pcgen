// Copyright (c) James Dempsey, 2009.
//
// Translation of pcgen.core.term.EQPlusTotalTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

/// Produces the PLUS token value: total plus modifier for the primary head.
class EQPlusTotalTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQPlusTotalTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    return (eq.calcPlusForHead(true) as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
