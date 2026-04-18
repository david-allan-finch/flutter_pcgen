// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCasterLevelTotalTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCasterLevelTotalTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCasterLevelTotalTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  /// If no spell is given, totals caster level across all spell classes.
  @override
  double? resolve(dynamic pc) => resolveWithSpell(pc, null);

  @override
  double? resolveWithSpell(dynamic pc, dynamic aSpell) {
    int iLev = 0;
    for (final pcClass in pc.getDisplay().getClassSet()) {
      if (pcClass.getSpellType() != 'NONE') {
        final classKey = pcClass.getKeyName() as String;
        final pcBonus = (pc.getTotalBonusTo('PCLEVEL', classKey) as num).toInt();
        final castBonus = (pc.getTotalBonusTo('CASTERLEVEL', classKey) as num).toInt();
        final iClass = (castBonus == 0) ? (pc.getDisplay().getLevel(pcClass) as num).toInt() : 0;
        final spellType = pcClass.getSpellType() as String;
        iLev += (pc.getTotalCasterLevelWithSpellBonus(
                aSpell, (aSpell == null) ? null : aSpell.getSpell(),
                spellType, classKey, iClass + pcBonus) as num)
            .toInt();
      }
    }
    return iLev.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
