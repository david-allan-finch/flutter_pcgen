// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMovementTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

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
