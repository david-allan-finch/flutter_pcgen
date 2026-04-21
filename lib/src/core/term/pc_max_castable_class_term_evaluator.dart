// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCMaxCastableClassTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCMaxCastableClassTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String classKey;

  PCMaxCastableClassTermEvaluator(String originalText, this.classKey) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getContext().getReferenceContext() to get ClassSpellList
    // and pc.getDisplay().getSpellLists(spClass) to check membership.
    // Returns -1.0 as stub (Java default when no matching class found).
    return -1.0;
  }

  @override
  bool isSourceDependant() => true;
}
