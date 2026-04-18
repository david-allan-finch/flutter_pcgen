// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilitiesNatureAutoTermEvaluator

import 'base_pc_count_abilities_nature_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountAbilitiesNatureAutoTermEvaluator extends BasePCCountAbilitiesNatureTermEvaluator
    implements TermEvaluator {
  PCCountAbilitiesNatureAutoTermEvaluator(
      String originalText, dynamic abCat, bool visible, bool hidden) {
    this.originalText = originalText;
    this.abCat = abCat;
    this.visible = visible;
    this.hidden = hidden;
  }

  @override
  List<dynamic> getAbilities(dynamic pc) {
    // Nature.AUTOMATIC
    return List.from(pc.getPoolAbilities(abCat, 'AUTOMATIC'));
  }

  @override
  bool isSourceDependant() => false;
}
