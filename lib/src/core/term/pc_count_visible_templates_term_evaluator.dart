// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountVisibleTemplatesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountVisibleTemplatesTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  PCCountVisibleTemplatesTermEvaluator(String originalText) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    double count = 0.0;
    for (final template in display.getTemplateSet()) {
      // TODO: Requires CDOMObjectKey.VISIBILITY and View.VISIBLE_EXPORT check.
      // Stub: counts all templates visible to export.
      if (template.isVisibleToExport() != false) {
        count++;
      }
    }
    return count;
  }

  @override
  bool isSourceDependant() => false;
}
