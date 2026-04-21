// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellsKnownTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountSpellsKnownTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final List<int> nums;

  PCCountSpellsKnownTermEvaluator(String originalText, this.nums) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires SettingsHandler.getPrintSpellsWithPC() and
    // Globals.getDefaultSpellBook(). Stub: sums character spell counts.
    double count = 0.0;
    if (nums[0] == -1) {
      for (final pcClass in pc.getDisplay().getClassSet()) {
        count += (pc.getCharacterSpellCount(pcClass) as num).toDouble();
      }
    } else {
      final pObj = pc.getSpellClassAtIndex(nums[0]);
      if (pObj != null) {
        // TODO: Requires Globals.getDefaultSpellBook()
        count = (pc.getCharacterSpells(pObj, null, '', nums[1]).length as num).toDouble();
      }
    }
    return count;
  }

  @override
  bool isSourceDependant() => false;
}
