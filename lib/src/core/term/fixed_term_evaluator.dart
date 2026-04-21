// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.FixedTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

/// A term evaluator that always returns a fixed integer value.
class FixedTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final int _value;

  FixedTermEvaluator(String originalText, this._value) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) => _value.toDouble();

  @override
  bool isSourceDependant() => true;

  bool isStatic() => false;
}
