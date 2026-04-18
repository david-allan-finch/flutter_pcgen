// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAttacksTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountAttacksTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountAttacksTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getNumAttacks() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
