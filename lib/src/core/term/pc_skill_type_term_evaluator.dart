// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSkillTypeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCSkillTypeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String type;

  PCSkillTypeTermEvaluator(String originalText, this.type) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    int count = 0;
    final skills = pc.getDisplay().getSkillSet();
    for (final sk in skills) {
      // TODO: Requires ObjectKey.VISIBILITY and View.HIDDEN_EXPORT check.
      // Stub: checks isType and qualifies without visibility filter.
      if (sk.isType(type) == true && sk.qualifies(pc, null) == true) {
        count++;
      }
    }
    return count.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
