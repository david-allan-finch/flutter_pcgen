// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCFavClassLevelTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class PCFavClassLevelTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCFavClassLevelTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return TermUtil.convertToFloat(originalText, evaluateDisplay(display));
  }

  @override
  String evaluateDisplay(dynamic display) {
    return (display.getFavoredClassLevel() as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
