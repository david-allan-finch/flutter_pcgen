// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.EQRaceReachTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_eq_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

class EQRaceReachTermEvaluator extends BaseEQTermEvaluator implements TermEvaluator {
  EQRaceReachTermEvaluator(String expressionString, String src) {
    originalText = expressionString;
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(originalText, evaluateForEquipment(eq, primary, pc));
  }

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) {
    // TODO: Requires FacetLibrary.getFacet(ReachFacet.class).getReach(pc.getCharID()).
    // Disabled when PCREACH control is used. Returns 0 as stub.
    return '0';
  }

  @override
  bool isSourceDependant() => true;
}
