// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSPellBaseStatTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCSPellBaseStatTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String classKey;

  PCSPellBaseStatTermEvaluator(String originalText, this.classKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    final aClass = pc.getClassKeyed(classKey);
    if (aClass == null) return 0.0;
    // TODO: Requires ObjectKey.SPELL_STAT and CDOMSingleRef for PCStat lookup.
    // Stub: attempts to get total stat from display.
    final ss = aClass.getSpellStat();
    if (ss == null) return 10.0;
    return (pc.getDisplay().getTotalStatFor(ss) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
