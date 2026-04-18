// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountFollowerTypeTransitiveTermEvaluator

import 'base_pcd_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountFollowerTypeTransitiveTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String type;
  final int index;
  final String newCount;

  PCCountFollowerTypeTransitiveTermEvaluator(
      String originalText, this.type, this.index, this.newCount) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    if (display.hasFollowers() == true) {
      final aList = <dynamic>[];
      for (final follower in display.getFollowerList()) {
        if ((follower.getType().getKeyName() as String).toLowerCase() == type.toLowerCase()) {
          aList.add(follower);
        }
      }
      if (index < aList.length) {
        final follower = aList[index];
        // TODO: Requires Globals.getPCList() to find the follower's PC and
        // evaluate getVariableValue. Returns 0.0 as stub.
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
