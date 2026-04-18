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

/// RaceTypeFacet is a Facet that determines the RaceType of a Player Character.
class RaceTypeFacet {
  dynamic templateFacet;
  dynamic raceFacet;
  dynamic companionModFacet;

  /// Returns the RaceType of the Player Character represented by the given
  /// CharID.
  dynamic getRaceType(CharID id) {
    dynamic raceType;
    final race = raceFacet.get(id);
    if (race != null) {
      final rt = race.get('RACETYPE');
      if (rt != null) {
        raceType = rt;
      }
    }
    for (final cm in companionModFacet.getSet(id)) {
      final rt = cm.get('RACETYPE');
      if (rt != null) {
        raceType = rt;
      }
    }
    for (final t in templateFacet.getSet(id)) {
      final rt = t.get('RACETYPE');
      if (rt != null) {
        raceType = rt;
      }
    }
    return raceType;
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }

  void setRaceFacet(dynamic raceFacet) {
    this.raceFacet = raceFacet;
  }

  void setCompanionModFacet(dynamic companionModFacet) {
    this.companionModFacet = companionModFacet;
  }
}
