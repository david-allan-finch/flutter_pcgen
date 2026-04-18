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

/// NonProficiencyPenaltyFacet is a Facet that calculates the Non-Proficiency
/// Penalty assessed when a Player Character is not proficient with a Weapon.
class NonProficiencyPenaltyFacet {
  dynamic templateFacet;

  /// Returns the Non-Proficiency Penalty assessed when a Player Character
  /// represented by the given CharID is not proficient with a Weapon.
  int getPenalty(CharID id) {
    // SettingsHandler.getGameAsProperty().get().getNonProfPenalty()
    int npp = _getGameNonProfPenalty();

    for (final t in templateFacet.getSet(id)) {
      final temp = t.get('NONPP') as int?;
      if (temp != null) {
        npp = temp;
      }
    }

    return npp;
  }

  /// Stub: returns default non-proficiency penalty from game settings.
  int _getGameNonProfPenalty() {
    // TODO: wire to SettingsHandler when available
    return -4;
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }
}
