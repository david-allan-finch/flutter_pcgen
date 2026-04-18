// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountMiscCompanionsTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountMiscCompanionsTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountMiscCompanionsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // PCStringKey.COMPANIONS
    final compString = display.getSafeStringFor('COMPANIONS') as String;
    final companions = compString.split(RegExp(r'\r?\n'));
    return companions.length.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
