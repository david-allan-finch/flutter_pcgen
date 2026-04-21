// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCStatModTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCStatModTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String statAbbrev;

  PCStatModTermEvaluator(String originalText, this.statAbbrev) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext() for PCStat lookup.
    // Passes statAbbrev as a string proxy to getStatModFor.
    return (display.getStatModFor(statAbbrev) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
