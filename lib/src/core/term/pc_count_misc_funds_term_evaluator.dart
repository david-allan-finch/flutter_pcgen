// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountMiscFundsTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountMiscFundsTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountMiscFundsTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // PCStringKey.ASSETS
    final fundString = display.getSafeStringFor('ASSETS') as String;
    final funds = fundString.split(RegExp(r'\r?\n'));
    return funds.length.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
