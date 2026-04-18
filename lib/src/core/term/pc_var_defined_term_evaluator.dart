// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCVarDefinedTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCVarDefinedTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String varName;

  PCVarDefinedTermEvaluator(String originalText, String var_) : varName = var_ {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return pc.hasVariable(varName) == true ? 1.0 : 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
