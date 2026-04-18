// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellClassesTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountSpellClassesTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountSpellClassesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getSpellClassCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
