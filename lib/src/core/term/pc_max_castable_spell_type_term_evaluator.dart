// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMaxCastableSpellTypeTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCMaxCastableSpellTypeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String typeKey;

  PCMaxCastableSpellTypeTermEvaluator(String originalText, this.typeKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    double max = 0.0;
    for (final spClass in pc.getDisplay().getClassSet()) {
      if ((spClass.getSpellType() as String).toLowerCase() == typeKey.toLowerCase()) {
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
    }
    return max;
  }

  @override
  bool isSourceDependant() => true;
}
