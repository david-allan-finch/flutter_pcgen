// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCTotalWeightTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCTotalWeightTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCTotalWeightTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    final charWeight = (display.getWeight() as num).toDouble();
    final totalWeight = (display.totalWeight() as num?)?.toInt() ?? 0;
    return charWeight + totalWeight;
  }

  @override
  bool isSourceDependant() => false;
}
