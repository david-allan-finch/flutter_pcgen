// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCHasDeityTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pcd_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCHasDeityTermEvaluator extends BasePCDTermEvaluator implements TermEvaluator {
  final String deity;

  PCHasDeityTermEvaluator(String originalText, this.deity) {
    this.originalText = originalText;
  }

  @override
  double? resolveDisplay(dynamic display) {
    // TODO: Requires Globals.getContext().getReferenceContext() for deity lookup
    // and ChannelUtilities.readControlledChannel for current deity.
    // Returns 0.0 as stub until context infrastructure is available.
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
