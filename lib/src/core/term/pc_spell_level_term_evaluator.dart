// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSpellLevelTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCSpellLevelTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCSpellLevelTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getSpellLevelTemp() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
