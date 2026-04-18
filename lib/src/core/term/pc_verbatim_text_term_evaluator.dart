// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCVerbatimTextTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCVerbatimTextTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCVerbatimTextTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  String evaluateDisplay(dynamic display) => originalText;

  @override
  double? resolveDisplay(dynamic display) => 0.0;

  @override
  bool isSourceDependant() => false;
}
