// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCShieldACcheckTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCShieldACcheckTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCShieldACcheckTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    double maxCheck = 0.0;
    for (final eq in pc.getEquipmentOfType('Shield', 1)) {
      maxCheck += (eq.preFormulaAcCheck(pc) as num).toDouble();
    }
    return maxCheck;
  }

  @override
  bool isSourceDependant() => false;
}
