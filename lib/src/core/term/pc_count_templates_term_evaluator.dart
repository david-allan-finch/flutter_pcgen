// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountTemplatesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountTemplatesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountTemplatesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    double count = 0.0;
    for (final template in display.getTemplateSet()) {
      // TODO: Requires ObjectKey.VISIBILITY and View.VISIBLE_EXPORT check.
      // Stub: counts all templates (same as Java when all are export-visible).
      if (template.isVisibleToExport() != false) {
        count++;
      }
    }
    return count;
  }

  @override
  bool isSourceDependant() => false;
}
