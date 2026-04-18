// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.ConstantZeroTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

/// A term evaluator that always returns 0.
class ConstantZeroTermEvaluator extends BasePCDTermEvaluator
    implements TermEvaluator {
  ConstantZeroTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) => 0.0;

  @override
  bool isSourceDependant() => false;

  bool isStatic() => true;
}
