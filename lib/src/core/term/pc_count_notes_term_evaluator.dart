// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountNotesTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountNotesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountNotesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getNotesCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
