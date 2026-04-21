// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCasterLevelRaceTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCasterLevelRaceTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCCasterLevelRaceTermEvaluator(String originalText, String src)
      : source = 'RACE.$src' {
    this.originalText = originalText;
  }

  /// Makes no sense without a spell.
  @override
  double? resolve(dynamic pc) => 0.0;

  @override
  double? resolveWithSpell(dynamic pc, dynamic aSpell) {
    if (aSpell == null) return 0.0;
    final lev = (pc.getTotalCasterLevelWithSpellBonus(
            aSpell, aSpell.getSpell(), 'NONE', source, 0) as num)
        .toDouble();
    return lev < 0.0 ? 0.0 : lev;
  }

  @override
  bool isSourceDependant() => true;
}
