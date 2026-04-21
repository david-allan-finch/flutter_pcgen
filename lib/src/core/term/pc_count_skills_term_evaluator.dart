// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSkillsTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountSkillsTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String filterToken;

  PCCountSkillsTermEvaluator(String originalText, this.filterToken) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    int count = 0;
    // TODO: Requires SkillFilter.getByToken and pc.getSkillFilter().
    // Uses VISIBLE_EXPORT view as per Java code (noted as potential bug in Java too).
    final skills = pc.getDisplay().getPartialSkillList('VISIBLE_EXPORT');
    for (final sk in skills) {
      if (pc.includeSkill(sk, filterToken) == true && sk.qualifies(pc, null) == true) {
        count++;
      }
    }
    return count.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
