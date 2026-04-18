// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCBaseSpellStatTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCBaseSpellStatTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCBaseSpellStatTermEvaluator(String originalText, this.source) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getContext().getReferenceContext() for class lookup.
    // Returns 0.0 as stub until full context is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => true;
}
