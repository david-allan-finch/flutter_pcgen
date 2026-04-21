// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSizeIntTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCSizeIntTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCSizeIntTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.sizeInt() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
