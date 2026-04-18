// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQBaseCostTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class EQBaseCostTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQBaseCostTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // ObjectKey.COST
    return eq.getSafe('COST').toString();
  }

  @override
  bool isSourceDependant() => false;
}
