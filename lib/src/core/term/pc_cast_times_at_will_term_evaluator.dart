// Copyright (c) James Dempsey, 2009.
//
// Translation of pcgen.core.term.PCCastTimesAtWillTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

/// Supplies the times per day value of the ATWILL constant (-1).
class PCCastTimesAtWillTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCastTimesAtWillTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) => -1.0;

  @override
  double? resolveWithSpell(dynamic pc, dynamic aSpell) => -1.0;

  @override
  bool isSourceDependant() => false;
}
