/*
 * Copyright (c) Thomas Parker, 2009.
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

import '../../enumeration/char_id.dart';

/// ReachFacet is a Facet that calculates the Reach for a Player Character.
class ReachFacet {
  dynamic templateFacet;
  dynamic raceFacet;
  dynamic bonusCheckingFacet;

  /// Returns the Reach for a Player Character represented by the given CharID.
  int getReach(CharID id) {
    final aRace = raceFacet.get(id);
    int reach = 0;
    if (aRace != null) {
      reach = aRace.getSafe('REACH') as int? ?? 0;
    }

    // Scan templates for any overrides
    for (final template in templateFacet.getSet(id)) {
      final r = template.get('REACH') as int?;
      if (r != null) {
        reach = r;
      }
    }
    reach += (bonusCheckingFacet.getBonus(id, 'COMBAT', 'REACH') as num).toInt();
    return reach;
  }

  /// Returns the Reach for a Player Character represented by the given CharID.
  int get(CharID id) {
    return getReach(id);
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }

  void setRaceFacet(dynamic raceFacet) {
    this.raceFacet = raceFacet;
  }

  void setBonusCheckingFacet(dynamic bonusCheckingFacet) {
    this.bonusCheckingFacet = bonusCheckingFacet;
  }

  void init() {
    // OutputDB.register("reach", this); // stub: GUI/output registration
  }
}
