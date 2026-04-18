// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQWeightTermEvaluator

import 'base_eq_term_evaluator.dart';
import 'term_evaluator.dart';

/// Returns the weight (in pounds) of an Equipment item, with special handling
/// for ammunition during cost calculation to avoid double-counting.
class EQWeightTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQWeightTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  String evaluate(dynamic eq) {
    if (eq.isCalculatingCost() && eq.isWeightAlreadyUsed()) {
      return '0';
    }
    final weight = eq.getWeightInPounds();
    if (eq.isCalculatingCost() && eq.isAmmunition()) {
      final unitWeight =
          (weight as num).toDouble() / eq.getSafe('BASE_QUANTITY');
      eq.setWeightAlreadyUsed(true);
      return unitWeight.toString();
    }
    eq.setWeightAlreadyUsed(true);
    return weight.toString();
  }

  @override
  bool isSourceDependant() => true;

  bool isStatic() => false;
}
