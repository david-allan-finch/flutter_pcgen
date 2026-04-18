// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSABTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountSABTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountSABTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getSpecialAbilityTimesList().length as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
