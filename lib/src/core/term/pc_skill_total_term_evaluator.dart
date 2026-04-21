// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSkillTotalTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCSkillTotalTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String total;

  PCSkillTotalTermEvaluator(String originalText, this.total) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getContext().getReferenceContext() for Skill lookup,
    // SkillRankControl.getTotalRank, and SkillModifier.modifier.
    // Stub: returns 0.0 until skill analysis infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
