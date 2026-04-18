// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermEvaluatorBuilderPCStat

import 'pc_stat_base_term_evaluator.dart';
import 'pc_stat_mod_term_evaluator.dart';
import 'pc_stat_total_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_evaluator_builder.dart';

/// A TermEvaluatorBuilder for PC stat references (e.g. "STR", "STRSCORE",
/// "STR.BASE", "STRSCORE.BASE").
class TermEvaluatorBuilderPCStat implements TermEvaluatorBuilder {
  final String _pattern;
  final List<String> _keys;
  final bool _entireTerm;

  TermEvaluatorBuilderPCStat(this._pattern, this._keys, this._entireTerm);

  @override
  String getTermConstructorPattern() => _pattern;

  @override
  List<String> getTermConstructorKeys() => _keys;

  @override
  bool isEntireTerm() => _entireTerm;

  @override
  TermEvaluator? getTermEvaluator(
      String expressionString, String src, String matchedSection) {
    if (expressionString == matchedSection) {
      return PCStatModTermEvaluator(expressionString, matchedSection);
    }
    if ('$matchedSection.BASE' == expressionString) {
      return PCStatBaseTermEvaluator(expressionString, matchedSection);
    }
    final rest = expressionString.substring(matchedSection.length);
    if (rest.startsWith('SCORE')) {
      if (expressionString.endsWith('.BASE')) {
        return PCStatBaseTermEvaluator(expressionString, matchedSection);
      }
      return PCStatTotalTermEvaluator(expressionString, matchedSection);
    }
    // Starts with stat abbreviation but not a recognized pattern.
    return null;
  }
}
