// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellRaceTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountSpellRaceTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountSpellRaceTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // Returns 1.0 if the first spell class object is a Race, 0.0 otherwise.
    // TODO: Requires isinstance check against Race type — using duck-typing as proxy.
    final aSpellRace = pc.getSpellClassAtIndex(0);
    try {
      // If the object has a getRace method or identifies as Race, return 1.0.
      // As a stub, check if it responds to isRace() or has runtimeType name "Race".
      if (aSpellRace != null && aSpellRace.runtimeType.toString().contains('Race')) {
        return 1.0;
      }
    } catch (_) {}
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
