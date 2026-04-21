// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilitiesNatureVirtualTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_count_abilities_nature_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountAbilitiesNatureVirtualTermEvaluator extends BasePCCountAbilitiesNatureTermEvaluator
    implements TermEvaluator {
  PCCountAbilitiesNatureVirtualTermEvaluator(
      String originalText, dynamic abCat, bool visible, bool hidden) {
    this.originalText = originalText;
    this.abCat = abCat;
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
