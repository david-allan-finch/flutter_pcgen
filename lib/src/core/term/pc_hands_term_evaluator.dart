// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHandsTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCHandsTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCHandsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires FacetLibrary.getFacet(HandsFacet.class).getHands(pc.getCharID()).
    // Returns 0.0 as stub until facet infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
