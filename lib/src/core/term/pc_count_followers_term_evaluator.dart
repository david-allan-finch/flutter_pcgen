// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountFollowersTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountFollowersTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountFollowersTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return (display.getFollowerCount() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
