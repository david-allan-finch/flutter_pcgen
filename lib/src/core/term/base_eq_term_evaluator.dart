// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.BaseEQTermEvaluator

import 'term_util.dart';

/// Abstract base for term evaluators that operate on Equipment.
abstract class BaseEQTermEvaluator {
  late String originalText;

  String evaluate(dynamic pc) => '0.0';
  String evaluateWithSpell(dynamic pc, dynamic aSpell) => '0.0';

  double? resolve(dynamic pc) =>
      TermUtil.convertToFloat(originalText, evaluate(pc));

  double? resolveWithSpell(dynamic pc, dynamic aSpell) => TermUtil.convertToFloat(
      originalText, evaluateWithSpell(pc, aSpell?.getSpell()));
}
