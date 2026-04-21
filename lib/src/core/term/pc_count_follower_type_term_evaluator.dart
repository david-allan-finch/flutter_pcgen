// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountFollowerTypeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountFollowerTypeTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String type;

  PCCountFollowerTypeTermEvaluator(String originalText, this.type) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    double count = 0.0;
    for (final follower in display.getFollowerList()) {
      if ((follower.getType().getKeyName() as String).toLowerCase() == type.toLowerCase()) {
        count++;
      }
    }
    return count;
  }

  @override
  bool isSourceDependant() => false;
}
