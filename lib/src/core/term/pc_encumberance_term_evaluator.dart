// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCEncumberanceTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class PCEncumberanceTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCEncumberanceTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return TermUtil.convertToFloat(originalText, evaluateDisplay(display));
  }

  @override
  String evaluateDisplay(dynamic display) {
    // Returns the ordinal of the Load enum (LIGHT=0, MEDIUM=1, HEAVY=2, etc.)
    final l = display.getLoadType();
    return (l.ordinal() as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
