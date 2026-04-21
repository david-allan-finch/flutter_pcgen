// Copyright (c) James Dempsey, 2009.
//
// Translation of pcgen.core.term.EQAltPlusTotalTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

/// Produces the ALTPLUSTOTAL token value: total plus modifier for the alternate head.
class EQAltPlusTotalTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQAltPlusTotalTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    return (eq.calcPlusForHead(false) as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
