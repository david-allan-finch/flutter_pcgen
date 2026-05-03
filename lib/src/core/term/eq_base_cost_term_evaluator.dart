// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQBaseCostTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQBaseCostTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQBaseCostTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // CDOMObjectKey.COST
    return eq.getSafeObject(CDOMObjectKey.getConstant('COST')).toString();
  }

  @override
  bool isSourceDependant() => false;
}
