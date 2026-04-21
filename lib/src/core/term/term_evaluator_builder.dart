// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermEvaluatorBuilder

import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaulator_exception.dart';

/// Interface for objects that can construct a [TermEvaluator] from a
/// matched pattern string.
abstract interface class TermEvaluatorBuilder {
  String getTermConstructorPattern();
  List<String> getTermConstructorKeys();
  bool isEntireTerm();
  TermEvaluator getTermEvaluator(
      String expressionString, String src, String matchedSection);
}
