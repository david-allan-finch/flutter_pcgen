// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQDamageDiceTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQDamageDiceTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQDamageDiceTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // Returns the number of dice (times) from a RollInfo on the damage string.
    // TODO: Requires RollInfo parsing of eq.getDamage(pc).
    // Stub: returns the damage dice count if available via getDamageDiceCount.
    try {
      return (eq.getDamageDiceCount(pc) as num).toString();
    } catch (_) {
      return '0.0';
    }
  }

  @override
  bool isSourceDependant() => false;
}
