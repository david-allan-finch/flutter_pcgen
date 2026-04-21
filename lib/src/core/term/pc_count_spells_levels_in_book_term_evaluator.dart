// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellsLevelsInBookTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountSpellsLevelsInBookTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final int classNum;
  final int sbookNum;

  PCCountSpellsLevelsInBookTermEvaluator(String originalText, List<int> nums)
      : classNum = nums[0],
        sbookNum = nums[1] {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getDefaultSpellBook().
    String bookName = '';
    if (sbookNum > 0) {
      bookName = pc.getDisplay().getSpellBookNames()[sbookNum] as String;
    }

    final pObj = pc.getSpellClassAtIndex(classNum);
    if (pObj != null) {
      for (int levelNum = 0; levelNum >= 0; ++levelNum) {
        final aList = pc.getCharacterSpells(pObj, null, bookName, levelNum);
        if ((aList as List).isEmpty) {
          return levelNum.toDouble();
        }
      }
    }
    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
