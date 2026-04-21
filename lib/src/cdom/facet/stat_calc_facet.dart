// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.cdom.facet.StatCalcFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/formula_key.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/non_stat_stat_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/non_stat_to_stat_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/stat_lock_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/stat_max_value_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/stat_min_value_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/analysis/unlocked_stat_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/bonus_checking_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/stat_value_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/variable_checking_facet.dart';

/// Calculates the effective values of PCStat objects for a Player Character,
/// taking into account locks, unlocks, bonuses, and min/max constraints.
class StatCalcFacet {
  late StatValueFacet statValueFacet;
  late StatLockFacet statLockFacet;
  late UnlockedStatFacet unlockedStatFacet;
  late NonStatStatFacet nonStatStatFacet;
  late NonStatToStatFacet nonStatToStatFacet;
  late StatMinValueFacet statMinValueFacet;
  late StatMaxValueFacet statMaxValueFacet;
  late VariableCheckingFacet variableCheckingFacet;
  late BonusCheckingFacet bonusCheckingFacet;

  /// Returns the total stat value (base + STAT bonus), subject to locks and
  /// min/max constraints.
  int getTotalStatFor(CharID id, PCStat stat) {
    int y = getBaseStatFor(id, stat);

    if (!nonStatToStatFacet.contains(id, stat)) {
      if (nonStatStatFacet.contains(id, stat)) return 10;
    }

    final (minStatValue, maxStatValue) = _getMinMax(id, stat);

    if (!unlockedStatFacet.contains(id, stat)) {
      final locked = statLockFacet.getLockedStat(id, stat);
      if (locked != null) {
        int total = locked.toInt() +
            bonusCheckingFacet.getBonus(id, 'LOCKEDSTAT', stat.getKeyName()).toInt();
        total = total.clamp(minStatValue, maxStatValue);
        return total;
      }
    }

    y += bonusCheckingFacet.getBonus(id, 'STAT', stat.getKeyName()).toInt();
    return y.clamp(minStatValue, maxStatValue);
  }

  /// Returns the base stat value before STAT bonuses.
  int getBaseStatFor(CharID id, PCStat stat) {
    if (!nonStatToStatFacet.contains(id, stat)) {
      if (nonStatStatFacet.contains(id, stat)) return 10;
    }

    final (minStatValue, maxStatValue) = _getMinMax(id, stat);

    if (!unlockedStatFacet.contains(id, stat)) {
      final locked = statLockFacet.getLockedStat(id, stat);
      if (locked != null) {
        return locked.toInt().clamp(minStatValue, maxStatValue);
      }
    }

    final z = variableCheckingFacet
        .getVariableValue(id, 'BASE.${stat.getKeyName()}')
        .toInt();
    if (z != 0) {
      return z.clamp(minStatValue, maxStatValue);
    }

    final score = statValueFacet.get(id, stat);
    return (score?.toInt() ?? 0).clamp(minStatValue, maxStatValue);
  }

  /// Returns the stat modifier for [stat] (e.g. the ability modifier).
  int getStatModFor(CharID id, PCStat stat) {
    return variableCheckingFacet
        .getVariableValue(
            id, stat.getSafeFormula(FormulaKey.statMod).toString(), 'STAT:${stat.getKeyName()}')
        .toInt();
  }

  int getModFornumber(CharID id, int aNum, PCStat stat) {
    return variableCheckingFacet
        .getVariableValue(
            id, stat.getSafeFormula(FormulaKey.statMod).toString(), aNum.toString())
        .toInt();
  }

  /// Returns the partial stat value using a pre-calculated [partialStatBonus].
  int getPartialStatFor(CharID id, PCStat stat, int partialStatBonus) {
    int statValue = getBaseStatFor(id, stat);
    statValue += partialStatBonus;

    final minVal = statMinValueFacet.getStatMinValue(id, stat);
    if (minVal != null) {
      statValue = statValue < minVal.toInt() ? minVal.toInt() : statValue;
    }
    final maxVal = statMaxValueFacet.getStatMaxValue(id, stat);
    if (maxVal != null) {
      statValue = statValue > maxVal.toInt() ? maxVal.toInt() : statValue;
    }
    return statValue;
  }

  (int min, int max) _getMinMax(CharID id, PCStat stat) {
    int minStatValue = -0x80000000; // Integer.MIN_VALUE
    final minVal = statMinValueFacet.getStatMinValue(id, stat);
    if (minVal != null) minStatValue = minVal.toInt();

    int maxStatValue = 0x7fffffff; // Integer.MAX_VALUE
    final maxVal = statMaxValueFacet.getStatMaxValue(id, stat);
    if (maxVal != null) maxStatValue = maxVal.toInt();

    return (minStatValue, maxStatValue);
  }
}
