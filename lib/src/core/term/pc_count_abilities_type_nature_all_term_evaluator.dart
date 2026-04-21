// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilitiesTypeNatureAllTermEvaluator

import 'package:flutter_pcgen/src/core/term/base_pc_count_abilities_type_term_evaluator.dart';
import 'package:flutter_pcgen/src/core/term/term_evaluator.dart';

class PCCountAbilitiesTypeNatureAllTermEvaluator extends BasePCCountAbilitiesTypeTermEvaluator
    implements TermEvaluator {
  PCCountAbilitiesTypeNatureAllTermEvaluator(
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
    // Nature.NORMAL (note: Java getPoolAbilities NORMAL for "ALL" type variant)
    return List.from(pc.getPoolAbilities(abCat, 'NORMAL'));
  }

  @override
  bool isSourceDependant() => false;
}
