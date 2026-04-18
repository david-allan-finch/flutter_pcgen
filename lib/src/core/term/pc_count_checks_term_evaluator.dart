// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountChecksTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountChecksTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountChecksTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext().getConstructedObjectCount(PCCheck.class)
    // Returns 0.0 as stub until context is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
