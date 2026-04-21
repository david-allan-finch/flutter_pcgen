// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountStatsTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

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
