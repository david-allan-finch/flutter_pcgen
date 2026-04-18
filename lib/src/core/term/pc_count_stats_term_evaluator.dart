// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountStatsTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountStatsTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountStatsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getStatCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
