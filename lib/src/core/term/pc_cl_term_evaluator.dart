// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCLTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_util.dart';

class PCCLTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String classKey;

  PCCLTermEvaluator(String originalText, String aClass)
      : classKey = aClass {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluate(pc));
  }

  @override
  String evaluate(dynamic pc) {
    final aClass = pc.getClassKeyed(classKey);
    if (aClass != null) {
      return (pc.getDisplay().getLevel(aClass) as num).toInt().toString();
    }
    return '0';
  }

  @override
  bool isSourceDependant() => true;
}
