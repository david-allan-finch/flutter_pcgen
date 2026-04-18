// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHasFeatTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCHasFeatTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String feat;

  PCHasFeatTermEvaluator(String originalText, this.feat) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // Uses FEAT category and checks both full name and name without choices.
    // TODO: Requires AbilityCategory.FEAT and AbilityUtilities.removeChoicesFromName.
    // Partial implementation using pc.hasAbilityKeyed directly.
    final hasFeat = pc.hasAbilityKeyed('FEAT', feat) == true;
    return hasFeat ? 1.0 : 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
