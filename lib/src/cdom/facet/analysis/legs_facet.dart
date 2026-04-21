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

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

/// LegsFacet is a Facet that tracks the number of Legs possessed by a Player
/// Character.
class LegsFacet {
  dynamic templateFacet;
  dynamic raceFacet;

  /// Returns the number of Legs possessed by the Player Character represented
  /// by the given CharID.
  int getLegs(CharID id) {
    final aRace = raceFacet.get(id);
    int legs = 0;
    if (aRace != null) {
      legs = aRace.getSafeInt(IntegerKey.legs) as int? ?? 0;
    }

    // Scan templates for any overrides
    for (final template in templateFacet.getSet(id)) {
      final l = template.get('LEGS') as int?;
      if (l != null) {
        legs = l;
      }
    }
    return legs;
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }

  void setRaceFacet(dynamic raceFacet) {
    this.raceFacet = raceFacet;
  }
}
