// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCArmourACcheckTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCArmourACcheckTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCArmourACcheckTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    int maxCheck = 0;
    for (final eq in pc.getEquipmentOfType('Armor', 1)) {
      maxCheck += (eq.preFormulaAcCheck(pc) as num).toInt();
    }
    return maxCheck.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
