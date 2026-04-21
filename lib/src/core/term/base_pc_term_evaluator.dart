// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BasePCTermEvaluator

import 'package:flutter_pcgen/src/core/term/term_util.dart';

/// Abstract base for term evaluators that resolve against a PlayerCharacter.
abstract class BasePCTermEvaluator {
  late String originalText;

  String evaluate(dynamic pc) {
    final r = resolve(pc);
    return r == null ? '0' : r.toInt().toString();
  }

  String evaluateWithSpell(dynamic pc, dynamic aSpell) => evaluate(pc);

  String evaluateForEquipment(dynamic eq, bool primary, dynamic pc) =>
      evaluate(pc);

  double? resolve(dynamic pc);

  double? resolveWithSpell(dynamic pc, dynamic aSpell) {
    return TermUtil.convertToFloat(
        originalText, evaluateWithSpell(pc, aSpell?.getSpell()));
  }

  double? resolveForEquipment(dynamic eq, bool primary, dynamic pc) {
    return TermUtil.convertToFloat(
        originalText, evaluateForEquipment(eq, primary, pc));
  }

  static double? convertToFloat(String element, String? foo) =>
      TermUtil.convertToFloat(element, foo);
}
