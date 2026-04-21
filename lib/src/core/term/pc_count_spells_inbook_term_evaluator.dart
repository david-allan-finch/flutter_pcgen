// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellsInbookTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountSpellsInbookTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final String book;

  PCCountSpellsInbookTermEvaluator(String originalText, this.book) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires SettingsHandler.getPrintSpellsWithPC() check.
    // Stub: always counts spells in book (conservative — may over-count).
    return (pc.countSpellsInBook(book) as num).toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
