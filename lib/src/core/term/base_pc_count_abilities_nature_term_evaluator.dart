// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BasePCCountAbilitiesNatureTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_count_abilities_term_evaluator.dart';

/// Abstract base for evaluators that count abilities by nature (NORMAL/AUTO/VIRTUAL/ALL).
abstract class BasePCCountAbilitiesNatureTermEvaluator extends BasePCCountAbilitiesTermEvaluator {
  @override
  double? resolve(dynamic pc) {
    return countVisibleAbilities(pc, getAbilities(pc), visible, hidden);
  }
}
