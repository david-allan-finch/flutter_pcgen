// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilitiesNatureAllTermEvaluator

import 'base_pc_count_abilities_nature_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountAbilitiesNatureAllTermEvaluator extends BasePCCountAbilitiesNatureTermEvaluator
    implements TermEvaluator {
  PCCountAbilitiesNatureAllTermEvaluator(
      String originalText, dynamic abCat, bool visible, bool hidden) {
    this.originalText = originalText;
    this.abCat = abCat;
    this.visible = visible;
    this.hidden = hidden;
  }

  @override
  List<dynamic> getAbilities(dynamic pc) {
    return List.from(pc.getCNAbilities(abCat));
  }

  @override
  bool isSourceDependant() => false;
}
