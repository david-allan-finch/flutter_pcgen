// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQACCheckTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQACCheckTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQACCheckTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // IntegerKey.AC_CHECK — deprecated when EQACCHECK CodeControl is used
    return (eq.getSafeInt(IntegerKey.acCheck) as num? ?? 0).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
