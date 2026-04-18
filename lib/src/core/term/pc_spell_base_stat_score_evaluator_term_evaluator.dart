// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSPellBaseStatScoreEvaluatorTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCSPellBaseStatScoreEvaluatorTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String classKey;

  PCSPellBaseStatScoreEvaluatorTermEvaluator(String originalText, this.classKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    final aClass = pc.getClassKeyed(classKey);
    if (aClass == null) return 0.0;
    // TODO: Requires ObjectKey.SPELL_STAT and CDOMSingleRef for PCStat lookup.
    // Stub: attempts to get stat mod directly from display.
    final ss = aClass.getSpellStat();
    if (ss == null) return 10.0;
    return (pc.getDisplay().getStatModFor(ss) as num? ?? 0).toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
