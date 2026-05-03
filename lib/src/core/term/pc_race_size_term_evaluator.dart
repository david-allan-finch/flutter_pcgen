// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCRaceSizeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCRaceSizeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCRaceSizeTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // Returns the safe value of FormulaKey.SIZE resolved for the race.
    // TODO: Requires formula resolution infrastructure.
    // Stub: returns the numeric size of the race if available.
    try {
      return (pc.getDisplay().getRace().getSafeObject(CDOMObjectKey.getConstant('SIZE')).resolve(pc, '') as num)
          .toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  @override
  bool isSourceDependant() => false;
}
