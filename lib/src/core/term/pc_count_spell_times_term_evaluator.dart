// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountSpellTimesTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountSpellTimesTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final int classNum;
  final int bookNum;
  final int spellLevel;
  final int spellNumber;

  PCCountSpellTimesTermEvaluator(String originalText, List<int> fields)
      : classNum = fields[0],
        bookNum = fields[1],
        spellLevel = (fields[0] == -1) ? -1 : fields[2],
        spellNumber = fields[3] {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    // TODO: Requires Globals.getDefaultSpellBook().
    String bookName;
    if (classNum == -1) {
      bookName = '';
    } else if (bookNum > 0) {
      bookName = pc.getDisplay().getSpellBookNames()[bookNum] as String;
    } else {
      bookName = '';
    }

    if (bookName.isNotEmpty || classNum == -1) {
      List<dynamic> csList = [];

      if (classNum == -1) {
        for (final cl in pc.getDisplay().getClassSet()) {
          for (final cs in pc.getCharacterSpells(cl, bookName)) {
            if (!csList.contains(cs)) {
              csList.add(cs);
            }
          }
        }
        csList.sort();
      } else {
        final pcClass = pc.getSpellClassAtIndex(classNum);
        if (pcClass != null) {
          csList = List.from(pc.getCharacterSpells(pcClass, null, bookName, spellLevel));
        }
      }

      if (spellNumber < csList.length) {
        final cs = csList[spellNumber];
        final si = cs.getSpellInfoFor(bookName, spellLevel);
        if (si != null) {
          return (si.getTimes() as num).toDouble();
        }
      }
    }

    return 0.0;
  }

  @override
  bool isSourceDependant() => false;
}
