// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountMiscMagicTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountMiscMagicTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountMiscMagicTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // PCStringKey.MAGIC
    final magicString = display.getSafeStringFor('MAGIC') as String;
    final magicList = magicString.split(RegExp(r'\r?\n'));
    return magicList.length.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
