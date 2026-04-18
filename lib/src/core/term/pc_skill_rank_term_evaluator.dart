// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSkillRankTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class PCSkillRankTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String rank;

  PCSkillRankTermEvaluator(String originalText, this.rank) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    return TermUtil.convertToFloat(originalText, evaluateDisplay(display));
  }

  @override
  String evaluateDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext() for Skill lookup.
    // Stub: looks up skill by key name directly.
    final skill = display.getSkillKeyed(rank);
    if (skill == null || display.hasSkill(skill) != true) {
      return '0.0';
    }
    return display.getRank(skill).toString();
  }

  @override
  bool isSourceDependant() => false;
}
