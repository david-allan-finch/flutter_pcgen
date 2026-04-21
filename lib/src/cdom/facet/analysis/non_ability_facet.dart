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

/// NonAbilityFacet is a Facet that tracks the Non-Abilities (PCStat objects)
/// that have been set on a Player Character.
class NonAbilityFacet {
  dynamic nonStatStatFacet;
  dynamic nonStatToStatFacet;

  /// Returns true if the given PCStat is not an ability for the Player
  /// Character identified by the given CharID.
  bool isNonAbility(CharID id, dynamic stat) {
    if (nonStatToStatFacet.contains(id, stat)) {
      return false;
    }
    return nonStatStatFacet.contains(id, stat) as bool;
  }

  void setNonStatStatFacet(dynamic nonStatStatFacet) {
    this.nonStatStatFacet = nonStatStatFacet;
  }

  void setNonStatToStatFacet(dynamic nonStatToStatFacet) {
    this.nonStatToStatFacet = nonStatToStatFacet;
  }
}
