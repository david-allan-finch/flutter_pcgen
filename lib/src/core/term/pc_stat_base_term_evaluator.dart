// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCStatBaseTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCStatBaseTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String statAbbrev;

  PCStatBaseTermEvaluator(String originalText, this.statAbbrev) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext() for PCStat lookup.
    // Passes statAbbrev as a string proxy to getBaseStatFor.
    return (display.getBaseStatFor(statAbbrev) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
