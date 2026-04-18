// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCModEquipTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCModEquipTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String modEq;

  PCModEquipTermEvaluator(String originalText, this.modEq) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return _process(pc).toDouble();
  }

  int _process(dynamic pc) {
    if (modEq == 'AC') {
      return (pc.modToACFromEquipment() as num).toInt();
    }
    if (modEq == 'ACCHECK') {
      return (pc.processOldAcCheck() as num).toInt();
    }
    if (modEq == 'MAXDEX') {
      return (pc.processOldMaxDex() as num).toInt();
    }
    if (modEq == 'SPELLFAILURE') {
      // TODO: Requires EqToken.getSpellFailureTokenInt for each equipped item.
      int bonus = 0;
      for (final eq in pc.getEquippedEquipmentSet()) {
        bonus += (eq.getSpellFailure(pc) as num? ?? 0).toInt();
      }
      bonus += (pc.getTotalBonusTo('MISC', 'SPELLFAILURE') as num).toInt();
      return bonus;
    }
    return 0;
  }

  @override
  bool isSourceDependant() => false;
}
