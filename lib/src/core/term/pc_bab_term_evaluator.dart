// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCBABTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCBABTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCBABTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.baseAttackBonus() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
