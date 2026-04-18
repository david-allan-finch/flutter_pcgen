// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMoveBaseTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class PCMoveBaseTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCMoveBaseTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return TermUtil.convertToFloat(originalText, evaluateDisplay(display));
  }

  @override
  String evaluateDisplay(dynamic display) {
    return (display.getBaseMovement() as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
