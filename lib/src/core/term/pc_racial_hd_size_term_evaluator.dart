// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCRacialHDSizeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCRacialHDSizeTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCRacialHDSizeTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getRacialHDSize() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
