// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilitiesTypeNatureVirtualTermEvaluator

import 'base_pc_count_abilities_type_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountAbilitiesTypeNatureVirtualTermEvaluator extends BasePCCountAbilitiesTypeTermEvaluator
    implements TermEvaluator {
  PCCountAbilitiesTypeNatureVirtualTermEvaluator(
      String originalText, dynamic abCat, List<String> types,
      bool visible, bool hidden) {
    this.originalText = originalText;
    this.abCat = abCat;
    this.types = types;
    this.visible = visible;
    this.hidden = hidden;
  }

  @override
  List<dynamic> getAbilities(dynamic pc) {
    // Nature.VIRTUAL
    return List.from(pc.getPoolAbilities(abCat, 'VIRTUAL'));
  }

  @override
  bool isSourceDependant() => false;
}
