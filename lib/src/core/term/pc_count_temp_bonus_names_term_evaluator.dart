// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountTempBonusNamesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountTempBonusNamesTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountTempBonusNamesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getNamedTempBonusList().length as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
