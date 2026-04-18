// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountDomainsTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountDomainsTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountDomainsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getDomainCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
