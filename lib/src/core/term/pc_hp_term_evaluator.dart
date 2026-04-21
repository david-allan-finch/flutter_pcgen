// Copyright (c) James Dempsey, 2009.
//
// Translation of pcgen.core.term.PCHPTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

/// Provides the internal variable HP: the character's maximum total hit points.
class PCHPTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCHPTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.hitPoints() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
