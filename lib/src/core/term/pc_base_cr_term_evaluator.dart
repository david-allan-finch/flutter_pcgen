// Copyright (c) Stefan Radermacher, 2014.
//
// Translation of pcgen.core.term.PCBaseCRTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

/// Calculates the character's unmodified challenge rating as specified by
/// the CR tag in the race definition.
class PCBaseCRTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCBaseCRTermEvaluator(String expressionString) {
    originalText = expressionString;
  }

  @override
  double? resolve(dynamic pc) {
    return (pc.getDisplay().calcBaseCR() as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
