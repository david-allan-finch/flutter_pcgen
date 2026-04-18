// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountLanguagesTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountLanguagesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountLanguagesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getLanguageCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
