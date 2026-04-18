// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCasterLevelClassTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCasterLevelClassTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCCasterLevelClassTermEvaluator(String originalText, this.source) {
    this.originalText = originalText;
  }

  /// Makes no sense without a spell.
  @override
  double? resolve(dynamic pc) => 0.0;

  @override
  double? resolveWithSpell(dynamic pc, dynamic aSpell) {
    if (aSpell == null) return 0.0;
    // TODO: Requires Globals.getContext().getReferenceContext() for domain/class lookup.
    // Returns 0.0 as stub until full context is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => true;
}
