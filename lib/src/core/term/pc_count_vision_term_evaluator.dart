// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountVisionTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountVisionTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountVisionTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getVisionCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
