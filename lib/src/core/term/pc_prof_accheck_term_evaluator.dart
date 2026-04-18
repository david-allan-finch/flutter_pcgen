// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCProfACCheckTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCProfACCheckTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String eqKey;

  PCProfACCheckTermEvaluator(String originalText, this.eqKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    if (eqKey.isEmpty) return 0.0;
    // TODO: Requires Globals.getContext().getReferenceContext() for equipment lookup.
    // Returns 0.0 as stub until context infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => true;
}
