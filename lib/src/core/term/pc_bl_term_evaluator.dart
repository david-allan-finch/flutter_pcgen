// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCBLTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCBLTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;

  PCBLTermEvaluator(String originalText, this.source) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    if (source.isEmpty) {
      return 0.0;
    }
    return (pc.getTotalBonusTo('PCLEVEL', source) as num).toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
