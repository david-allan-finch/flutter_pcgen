// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCScoreTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCScoreTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String stat;

  PCScoreTermEvaluator(String originalText, this.stat) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    if (stat.isEmpty) return 0.0;
    // TODO: Requires Globals.getContext().getReferenceContext() for PCStat lookup.
    // Returns getTotalStatFor with the stat key as a string proxy.
    return (display.getTotalStatFor(stat) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
