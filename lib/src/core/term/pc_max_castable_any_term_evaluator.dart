// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMaxCastableAnyTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCMaxCastableAnyTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCMaxCastableAnyTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    double max = 0.0;
    for (final spClass in pc.getDisplay().getClassSet()) {
      final spellSupport = pc.getSpellSupport(spClass);
      final cutoff = (spellSupport.getHighestLevelSpell() as num).toInt();
      if (spellSupport.hasCastList() == true) {
        for (int i = 0; i < cutoff; i++) {
          if ((spellSupport.getCastForLevel(i, pc) as num) != 0) {
            if (i > max) max = i.toDouble();
          }
        }
      } else {
        for (int i = 0; i < cutoff; i++) {
          if ((spellSupport.getKnownForLevel(i, pc) as num) != 0) {
            if (i > max) max = i.toDouble();
          }
        }
      }
    }
    return max;
  }

  @override
  bool isSourceDependant() => true;
}
