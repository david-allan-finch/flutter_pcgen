// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountContainersTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountContainersTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  PCCountContainersTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // MERGE_ALL = 0 in Java Constants
    final eList = pc.getEquipmentListInOutputOrder(0);
    int count = 0;
    for (final eq in eList) {
      if (eq.isContainer() == true) {
        count++;
      }
    }
    return count.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
