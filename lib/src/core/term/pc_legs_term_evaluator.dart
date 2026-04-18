// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCLegsTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCLegsTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCLegsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getDisplay().getPreFormulaLegs() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
