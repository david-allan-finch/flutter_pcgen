// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.BonusCheckingFacet

import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';
import 'package:flutter_pcgen/src/cdom/facet/player_character_tracking_facet.dart';

/// A transition-class facet that provides access to bonus values on a Player
/// Character. Delegates to [PlayerCharacterTrackingFacet] to get the PC and
/// then queries the PC for bonus values.
///
/// Note: this is distinct from [BonusActivationFacet]. This facet is about the
/// *aggregated numerical results* of bonus calculations.
class BonusCheckingFacet {
  late PlayerCharacterTrackingFacet trackingFacet;

  /// Returns the total bonus of [bonusType]/[bonusName] for the PC.
  double getBonus(CharID id, String bonusType, String bonusName) {
    final pc = trackingFacet.getPC(id);
    return pc.getTotalBonusTo(bonusType, bonusName);
  }

  /// Calculates the sum of bonuses from [bonuses], each resolved against
  /// [sourceIdentifier].
  double getAllBonusValues(
      CharID id, Iterable<BonusObj> bonuses, String sourceIdentifier) {
    final pc = trackingFacet.getPC(id);
    double value = 0;
    for (final bo in bonuses) {
      value += bo.resolve(pc, sourceIdentifier).toDouble();
    }
    return value;
  }

  /// Sums bonuses from [map] (BonusObj → source CDOMObject) for the PC.
  double calcBonus(CharID id, Map<BonusObj, CDOMObject> map) {
    final pc = trackingFacet.getPC(id);
    double total = 0;
    for (final entry in map.entries) {
      total += entry.key.resolve(pc, entry.value.getQualifiedKey()).toDouble();
    }
    return total;
  }

  /// Returns expanded bonus info strings for the given [bonusName], with
  /// %LIST entries replaced by the actual choices made.
  List<String> getExpandedBonusInfo(CharID id, String bonusName) {
    final pc = trackingFacet.getPC(id);
    final list = <String>[];
    for (final bonus in pc.getActiveBonusList()) {
      if (bonus.getTypeOfBonus() == bonusName) {
        final bonusInfo = bonus.getBonusInfo();
        if (bonusInfo.contains('%LIST')) {
          for (final bp in pc.getStringListFromBonus(bonus)) {
            var key = bp.fullyQualifiedBonusType;
            if (key.startsWith(bonusName)) {
              key = key.substring(bonusName.length + 1);
            }
            list.add(key);
          }
        } else {
          list.add(bonusInfo);
        }
      }
    }
    return list;
  }
}
