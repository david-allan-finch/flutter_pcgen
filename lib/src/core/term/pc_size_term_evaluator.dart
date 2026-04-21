// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCSizeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class PCSizeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCSizeTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluate(pc));
  }

  @override
  String evaluate(dynamic pc) {
    return (pc.sizeInt() as num).toInt().toString();
  }

  @override
  bool isSourceDependant() => false;
}
