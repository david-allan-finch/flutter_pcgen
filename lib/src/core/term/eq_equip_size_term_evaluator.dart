// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQEquipSizeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQEquipSizeTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQEquipSizeTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    return eq.getSize() as String;
  }

  @override
  bool isSourceDependant() => false;
}
