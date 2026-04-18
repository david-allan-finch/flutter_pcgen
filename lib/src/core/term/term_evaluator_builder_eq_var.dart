// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.TermEvaluatorBuilderEQVar

import 'eq_accheck_term_evaluator.dart';
import 'eq_alt_plus_total_term_evaluator.dart';
import 'eq_base_cost_term_evaluator.dart';
import 'eq_crit_mult_term_evaluator.dart';
import 'eq_damage_dice_term_evaluator.dart';
import 'eq_damage_die_term_evaluator.dart';
import 'eq_equip_size_term_evaluator.dart';
import 'eq_hands_term_evaluator.dart';
import 'eq_head_plus_total_term_evaluator.dart';
import 'eq_plus_total_term_evaluator.dart';
import 'eq_race_reach_term_evaluator.dart';
import 'eq_range_term_evaluator.dart';
import 'eq_reach_mult_term_evaluator.dart';
import 'eq_reach_term_evaluator.dart';
import 'eq_size_term_evaluator.dart';
import 'eq_spell_failure_term_evaluator.dart';
import 'eq_weight_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_evaluator_builder.dart';

/// Enum of TermEvaluatorBuilders for Equipment-context term variables.
enum TermEvaluatorBuilderEQVar implements TermEvaluatorBuilder {
  completeEqAltplusTotal(
      'ALTPLUSTOTAL', ['ALTPLUSTOTAL'], true),
  completeEqBasecost(
      'BASECOST', ['BASECOST'], true),
  completeEqCritmult(
      'CRITMULT', ['CRITMULT'], true),
  completeEqDmgdice(
      'DMGDICE', ['DMGDICE'], true),
  completeEqDmgdie(
      'DMGDIE', ['DMGDIE'], true),
  completeEqEqaccheck(
      'EQACCHECK', ['EQACCHECK'], true),
  completeEqEqhands(
      'EQHANDS', ['EQHANDS'], true),
  completeEqEqspellfail(
      'EQSPELLFAIL', ['EQSPELLFAIL'], true),
  completeEqEquipSizeInt(
      r'EQUIP\.SIZE(?:\.INT)?', ['EQUIP.SIZE.INT', 'EQUIP.SIZE'], true),
  completeEqHeadplustotal(
      'HEADPLUSTOTAL', ['HEADPLUSTOTAL'], true),
  completeEqPlustotal(
      'PLUSTOTAL', ['PLUSTOTAL'], true),
  completeEqRange(
      'RANGE', ['RANGE'], true),
  completeEqReachmult(
      r'(?:RACEREACH|REACHMULT|REACH)', ['RACEREACH', 'REACHMULT', 'REACH'], true),
  completeEqSize(
      'SIZE', ['SIZE'], true),
  completeEqWt(
      'WT', ['WT'], true);

  const TermEvaluatorBuilderEQVar(
      this._pattern, this._keys, this._entireTerm);

  final String _pattern;
  final List<String> _keys;
  final bool _entireTerm;

  @override
  String getTermConstructorPattern() => _pattern;

  @override
  List<String> getTermConstructorKeys() => _keys;

  @override
  bool isEntireTerm() => _entireTerm;

  @override
  TermEvaluator? getTermEvaluator(
      String expressionString, String src, String matchedSection) {
    switch (this) {
      case completeEqAltplusTotal:
        return EQAltPlusTotalTermEvaluator(expressionString);
      case completeEqBasecost:
        return EQBaseCostTermEvaluator(expressionString);
      case completeEqCritmult:
        return EQCritMultTermEvaluator(expressionString);
      case completeEqDmgdice:
        return EQDamageDiceTermEvaluator(expressionString);
      case completeEqDmgdie:
        return EQDamageDieTermEvaluator(expressionString);
      case completeEqEqaccheck:
        return EQACCheckTermEvaluator(expressionString);
      case completeEqEqhands:
        return EQHandsTermEvaluator(expressionString);
      case completeEqEqspellfail:
        return EQSpellFailureTermEvaluator(expressionString);
      case completeEqEquipSizeInt:
        if (expressionString.endsWith('.INT')) {
          return EQSizeTermEvaluator(expressionString);
        }
        return EQEquipSizeTermEvaluator(expressionString);
      case completeEqHeadplustotal:
        return EQHeadPlusTotalTermEvaluator(expressionString);
      case completeEqPlustotal:
        return EQPlusTotalTermEvaluator(expressionString);
      case completeEqRange:
        return EQRangeTermEvaluator(expressionString);
      case completeEqReachmult:
        if (matchedSection == 'RACEREACH') {
          return EQRaceReachTermEvaluator(expressionString, src);
        } else if (matchedSection == 'REACHMULT') {
          return EQReachMultTermEvaluator(expressionString);
        }
        return EQReachTermEvaluator(expressionString);
      case completeEqSize:
        return EQSizeTermEvaluator(expressionString);
      case completeEqWt:
        return EQWeightTermEvaluator(expressionString);
    }
  }
}
