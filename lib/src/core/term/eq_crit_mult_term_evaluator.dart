// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQCritMultTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class EQCritMultTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQCritMultTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    // Deprecated when CRITMULT control is used
    if (primary) {
      return (eq.getCritMultiplier() as num).toDouble();
    }
    return (eq.getAltCritMultiplier() as num).toDouble();
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // Returns multiplier as string (e.g. "x2")
    if (primary) {
      return 'x${(eq.getCritMultiplier() as num).toInt()}';
    }
    return 'x${(eq.getAltCritMultiplier() as num).toInt()}';
  }

  @override
  bool isSourceDependant() => false;
}
