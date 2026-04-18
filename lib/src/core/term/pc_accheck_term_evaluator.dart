// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCACcheckTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCACcheckTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCACcheckTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // Sums preFormulaAcCheck for all Armor and Shield equipment
    int maxCheck = 0;
    for (final eq in pc.getEquipmentOfType('Armor', 1)) {
      maxCheck += (eq.preFormulaAcCheck(pc) as num).toInt();
    }
    for (final eq in pc.getEquipmentOfType('Shield', 1)) {
      maxCheck += (eq.preFormulaAcCheck(pc) as num).toInt();
    }
    return maxCheck.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
