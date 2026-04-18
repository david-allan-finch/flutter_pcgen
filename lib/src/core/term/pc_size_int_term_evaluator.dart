// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSizeIntTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

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
