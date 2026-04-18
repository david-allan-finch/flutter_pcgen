// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCStatTotalTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCStatTotalTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String statAbbrev;

  PCStatTotalTermEvaluator(String originalText, this.statAbbrev) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext() for PCStat lookup.
    // Passes statAbbrev as a string proxy to getTotalStatFor.
    return (display.getTotalStatFor(statAbbrev) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
