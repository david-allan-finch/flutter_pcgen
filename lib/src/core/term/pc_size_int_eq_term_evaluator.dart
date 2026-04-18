// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSizeIntEQTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCSizeIntEQTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCSizeIntEQTermEvaluator(String expressionString, this.source) {
    originalText = expressionString;
  }

  @override
  double? resolve(dynamic pc) {
    int modSize = 0;
    final eq = pc.getEquipmentNamed(source);
    if (eq != null) {
      // Check weapon prof bonus
      final ref = eq.getWeaponProf();
      if (ref != null) {
        final profName = ref.getKeyName() as String;
        modSize = (pc.getTotalBonusTo('WEAPONPROF=$profName', 'PCSIZE') as num).toInt();
      }
      // Check each equipment type
      for (final eqType in eq.typeList()) {
        final i = (pc.getTotalBonusTo('WEAPONPROF=TYPE.$eqType', 'PCSIZE') as num).toInt();
        if (modSize < i) {
          modSize = i;
        }
      }
    }
    return ((pc.sizeInt() as num).toInt() + modSize).toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
