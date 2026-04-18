// Copyright (c) Thomas Parker, 2010.
//
// Translation of pcgen.core.term.PCMaxLevelTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCMaxLevelTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String classKey;

  PCMaxLevelTermEvaluator(String originalText, String sourceInfo)
      : classKey = sourceInfo {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    if (classKey.isEmpty) return 0.0;
    final aClass = pc.getClassKeyed(classKey);
    if (aClass == null) return 0.0;
    final level = (pc.getSpellSupport(aClass)
            .getMaxSpellLevelForClassLevel(pc.getDisplay().getLevel(aClass)) as num)
        .toInt();
    return level.toDouble();
  }

  @override
  bool isSourceDependant() => true;
}
