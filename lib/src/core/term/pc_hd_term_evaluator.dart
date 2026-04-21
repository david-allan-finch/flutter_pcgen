// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHDTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCHDTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCHDTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.totalHitDice() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
