// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountAbilityNameTermEvaluator

import 'base_pc_count_abilities_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountAbilityNameTermEvaluator extends BasePCCountAbilitiesTermEvaluator
    implements TermEvaluator {
  final String key;
  // visible and hidden override the base class fields for this evaluator
  final bool _visible;
  final bool _hidden;

  PCCountAbilityNameTermEvaluator(
      String originalText, dynamic abCat, this.key, this._visible, this._hidden) {
    this.originalText = originalText;
    this.abCat = abCat;
    visible = _visible;
    hidden = _hidden;
  }

  @override
  double? resolve(dynamic pc) {
    double count = 0.0;
    final abilityList = getAbilities(pc);
    for (final anAbility in abilityList) {
      if ((anAbility.getAbilityKey() as String).toLowerCase() == key.toLowerCase()) {
        count += countVisibleAbility(pc, anAbility, _visible, _hidden, false);
        break;
      }
    }
    return count;
  }

  @override
  List<dynamic> getAbilities(dynamic pc) {
    return List.from(pc.getCNAbilities(abCat));
  }

  @override
  bool isSourceDependant() => false;
}
