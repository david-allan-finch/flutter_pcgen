// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountRaceSubTypesTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountRaceSubTypesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountRaceSubTypesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getRacialSubTypeCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
