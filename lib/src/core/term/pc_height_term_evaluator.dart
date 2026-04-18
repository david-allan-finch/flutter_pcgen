// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHeightTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCHeightTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCHeightTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires HeightCompat.getCurrentHeight(display.getCharID()).
    // Returns 0.0 as stub until compat infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
