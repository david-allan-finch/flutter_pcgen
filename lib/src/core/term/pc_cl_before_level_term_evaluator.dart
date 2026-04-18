// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCLBeforeLevelTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCLBeforeLevelTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String source;
  final int level;

  PCCLBeforeLevelTermEvaluator(String originalText, this.source, this.level) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    final aClass = pc.getClassKeyed(source);
    if (aClass != null) {
      if (level > 0) {
        return (pc.getLevelBefore(aClass.getKeyName(), level) as num).toDouble();
      }
      return (pc.getDisplay().getLevel(aClass) as num).toDouble();
    }
    return 0.0;
  }

  @override
  bool isSourceDependant() => true;
}
