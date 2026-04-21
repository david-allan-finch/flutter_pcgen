// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMoveBaseTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

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
