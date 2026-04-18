// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMovementTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class PCMovementTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String movement;

  PCMovementTermEvaluator(String originalText, this.movement) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return TermUtil.convertToFloat(originalText, evaluateDisplay(display));
  }

  @override
  String evaluateDisplay(dynamic display) {
    return (display.movementOfType(movement) as num).toString();
  }

  @override
  bool isSourceDependant() => false;
}
