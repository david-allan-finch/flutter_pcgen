// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountClassesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountClassesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountClassesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    double s = (display.getClassCount() as num).toDouble();
    // TODO: Requires SettingsHandler.hideMonsterClasses() check.
    // Stub: counts all classes including monster classes.
    return s;
  }

  @override
  bool isSourceDependant() => false;
}
