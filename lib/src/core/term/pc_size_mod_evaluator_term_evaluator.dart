// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSizeModEvaluatorTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCSizeModEvaluatorTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCSizeModEvaluatorTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getSizeAdjustmentBonusTo('COMBAT', 'AC') as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
