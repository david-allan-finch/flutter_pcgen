// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHasClassTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCHasClassTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCHasClassTermEvaluator(String originalText, this.source) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return pc.getClassKeyed(source) != null ? 1.0 : 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
