// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCEqTypeTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class PCEqTypeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  static final RegExp _fpRegex = RegExp(
      r'^[\x00-\x20]*[+-]?(NaN|Infinity|((\d+(\.)?\d*([eE][+-]?\d+)?)|(\.\d+([eE][+-]?\d+)?)|(((0[xX][0-9a-fA-F]+(\.)?)|(0[xX][0-9a-fA-F]*(\.)[0-9a-fA-F]+))[pP][+-]?\d+))[fFdD]?)[\x00-\x20]*$');

  PCEqTypeTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    final sTok = evaluate(pc);
    if (_fpRegex.hasMatch(sTok)) {
      return TermUtil.convertToFloat(originalText, sTok);
    }
    return 0.0;
  }

  @override
  String evaluate(dynamic pc) {
    // TODO: Requires EqTypeToken.getToken(originalText, pc, null).
    // Returns originalText as a stub.
    return originalText;
  }

  @override
  bool isSourceDependant() => false;
}
