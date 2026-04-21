// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BasePCDTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_util.dart';

/// Abstract base for term evaluators that delegate to a CharacterDisplay
/// rather than directly to PlayerCharacter.
abstract class BasePCDTermEvaluator extends BasePCTermEvaluator {
  @override
  String evaluate(dynamic pc) => evaluateDisplay(pc.getDisplay());

  String evaluateDisplay(dynamic display) {
    final r = resolveDisplay(display);
    return r == null ? '0' : r.toInt().toString();
  }

  @override
  String evaluateWithSpell(dynamic pc, dynamic aSpell) =>
      evaluateDisplayWithSpell(pc.getDisplay(), aSpell);

  String evaluateDisplayWithSpell(dynamic display, dynamic aSpell) =>
      evaluateDisplay(display);

  @override
  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) =>
      evaluate(pc);

  @override
  double? resolve(dynamic pc) => resolveDisplay(pc.getDisplay());

  double? resolveDisplay(dynamic display);

  @override
  double? resolveWithSpell(dynamic pc, dynamic aSpell) {
    return TermUtil.convertToFloat(
        originalText, evaluateWithSpell(pc, aSpell?.getSpell()));
  }

  @override
  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(
        originalText, evaluateForEquipment(eq, primary, pc));
  }
}
