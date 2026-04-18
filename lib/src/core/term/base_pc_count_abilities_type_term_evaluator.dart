// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BasePCCountAbilitiesTypeTermEvaluator

import 'base_pc_count_abilities_term_evaluator.dart';

/// Abstract base for evaluators that count abilities filtered by type.
abstract class BasePCCountAbilitiesTypeTermEvaluator extends BasePCCountAbilitiesTermEvaluator {
  List<String> types = [];

  @override
  double? resolve(dynamic pc) {
    double count = 0.0;
    for (final anAbility in getAbilities(pc)) {
      for (final type in types) {
        if (anAbility.getAbility().isType(type) == true) {
          count += countVisibleAbility(pc, anAbility, visible, hidden, false);
          break;
        }
      }
    }
    return count;
  }
}
