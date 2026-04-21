// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQHandsTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQHandsTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQHandsTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // IntegerKey.SLOTS
    return (eq.getSafeObject(ObjectKey.getConstant('SLOTS')) as num? ?? 0).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
