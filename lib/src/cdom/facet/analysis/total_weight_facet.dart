/*
 * Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// TotalWeightFacet performs calculations related to the total weight of
/// Equipment carried by a Player Character (does not include the body weight).
class TotalWeightFacet {
  // @Autowired
  dynamic trackingFacet; // PlayerCharacterTrackingFacet

  dynamic equipmentFacet;

  /// Returns the total Equipment weight for the Player Character identified by
  /// the given CharID.
  double getTotalWeight(CharID id) {
    double totalWeight = 0;
    const double floatZero = 0.0;
    // Globals.checkRule(RuleConstants.CLOTHINGENCUMBRANCE)
    bool firstClothing = !_checkClothingEncumbrance();

    final pc = trackingFacet.getPC(id);
    for (final eq in equipmentFacet.getSet(id)) {
      final carried = eq.getCarried() as double? ?? 0.0;
      if (carried > floatZero && eq.getParent() == null) {
        if ((eq.getChildCount() as int) > 0) {
          totalWeight += (eq.getWeightAsDouble(pc) as double) +
              (eq.getContainedWeight(pc) as double);
        } else {
          if (firstClothing &&
              (eq.isEquipped() as bool) &&
              (eq.isType('CLOTHING') as bool)) {
            // The first equipped set of clothing should have a weight of 0.
            // Feature #437410
            firstClothing = false;
            totalWeight +=
                (eq.getWeightAsDouble(pc) as double) * [carried - 1, 0.0].reduce((a, b) => a > b ? a : b);
          } else {
            totalWeight += (eq.getWeightAsDouble(pc) as double) * carried;
          }
        }
      }
    }

    return totalWeight;
  }

  /// Stub: checks CLOTHINGENCUMBRANCE rule.
  bool _checkClothingEncumbrance() {
    // TODO: wire to Globals.checkRule(RuleConstants.CLOTHINGENCUMBRANCE)
    return false;
  }

  void setEquipmentFacet(dynamic equipmentFacet) {
    this.equipmentFacet = equipmentFacet;
  }
}
