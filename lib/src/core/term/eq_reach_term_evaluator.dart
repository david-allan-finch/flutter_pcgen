// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQReachTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

/// Returns the reach of an Equipment item.
class EQReachTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQReachTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  String evaluate(dynamic eq) {
    // Disabled if EQREACH control is active — caller should check.
    return eq.getSafeInt(IntegerKey.reach).toString();
  }

  @override
  bool isSourceDependant() => true;

  bool isStatic() => false;
}
