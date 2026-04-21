// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSpellLevelTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCSpellLevelTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCSpellLevelTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getSpellLevelTemp() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
