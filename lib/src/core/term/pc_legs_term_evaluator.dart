// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCLegsTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCLegsTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCLegsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getDisplay().getPreFormulaLegs() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
