// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMaxCastableDomainTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCMaxCastableDomainTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String domainKey;

  PCMaxCastableDomainTermEvaluator(String originalText, this.domainKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getContext().getReferenceContext() for domain lookup
    // and pc.getDomainSource(domain) for class resolution.
    // Returns 0.0 as stub until context infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => true;
}
