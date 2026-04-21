// Copyright (c) Thomas Parker, 2012.
//
// Translation of pcgen.cdom.facet.StatBonusFacet

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_utilities.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'bonus_checking_facet.dart';
import 'model/stat_facet.dart';
import 'prerequisite_facet.dart';

/// Calculates bonuses contributed by [PCStat] objects for a Player Character.
class StatBonusFacet {
  late BonusCheckingFacet bonusCheckingFacet;
  late PrerequisiteFacet prerequisiteFacet;
  late StatFacet statFacet;

  /// Returns a map of [BonusObj] → [PCStat] for bonuses of [aType]/[aName]
  /// granted by any stat on the PC.
  Map<BonusObj, PCStat> getBonusListOfType(
      CharID id, String aType, String aName) {
    final result = <BonusObj, PCStat>{};
    for (final stat in statFacet.getSet(id)) {
      final bonuses = BonusUtilities.getBonusFromList(
          stat.getSafeListFor(ListKey.getConstant<BonusObj>('BONUS')),
          aType,
          aName);
      for (final bonus in bonuses) {
        result[bonus] = stat;
      }
    }
    return result;
  }

  /// Returns the aggregate bonus value for [type]/[name] from all stats,
  /// filtered by prerequisites.
  double getStatBonusTo(CharID id, String type, String name) {
    final map = getBonusListOfType(id, type.toUpperCase(), name.toUpperCase());
    map.removeWhere(
        (bonus, stat) => !prerequisiteFacet.qualifies(id, bonus, stat));
    return bonusCheckingFacet.calcBonus(id, map);
  }
}
