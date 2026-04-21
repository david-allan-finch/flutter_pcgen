// Copyright (c) Stefan Radermacher, 2014.
//
// Translation of pcgen.core.term.PCBaseHDTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

/// Calculates the character's unmodified number of racial hit dice,
/// as specified by the MONSTERCLASS tag in the race definition.
class PCBaseHDTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCBaseHDTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getDisplay().getBaseHD() as num?)?.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
