// Copyright (c) James Dempsey, 2009.
//
// Translation of pcgen.core.term.EQHeadPlusTotalTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

/// Produces the HEADPLUSTOTAL token: total plus modifier for the current head.
class EQHeadPlusTotalTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQHeadPlusTotalTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    return (eq.calcPlusForHead(primary) as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
