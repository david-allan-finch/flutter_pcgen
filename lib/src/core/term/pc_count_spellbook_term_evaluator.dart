// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellbookTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountSpellbookTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountSpellbookTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getSpellBookCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
