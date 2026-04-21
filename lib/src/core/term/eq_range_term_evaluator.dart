// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQRangeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQRangeTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQRangeTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // IntegerKey.RANGE — deprecated when RANGE CodeControl is used
    return (eq.getSafeInt(IntegerKey.range) as num? ?? 0).toString();
  }

  @override
  bool isSourceDependant() => true;
}
