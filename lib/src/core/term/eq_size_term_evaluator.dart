// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQSizeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

/// Returns the integer size category of an Equipment item.
class EQSizeTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQSizeTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  String evaluate(dynamic eq) => eq.sizeInt().toString();

  @override
  double? resolve(dynamic eq) => (eq.sizeInt() as int).toDouble();

  @override
  bool isSourceDependant() => true;

  bool isStatic() => false;
}
