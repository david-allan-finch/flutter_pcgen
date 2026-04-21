// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCBonusLangTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCBonusLangTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCBonusLangTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.checkRule(RuleConstants.INTBONUSLANG).
    // Partial implementation: computes count - currentLangCount without the
    // INTBONUSLANG rule check.
    final display = pc.getDisplay();
    final nml = (display.totalNonMonsterLevels() as num).toInt();
    final hd = (display.totalHitDice() as num).toInt();
    if ((nml > 1) || (nml > 0 && hd > 0)) {
      // TODO: check Globals.checkRule(RuleConstants.INTBONUSLANG)
      // For now, skip the bonus lang in this case (conservative stub).
      return 0.0;
    }
    final count = (pc.getBonusLanguageCount() as num).toInt();
    final a = pc.getBonusLanguageAbility();
    final currentLangCount = (pc.getDetailedAssociationCount(a) as num).toInt();
    return (count - currentLangCount).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
