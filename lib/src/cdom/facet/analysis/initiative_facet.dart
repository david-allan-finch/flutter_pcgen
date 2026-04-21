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

/// InitiativeFacet is a Facet that calculates the Initiative value for a Player
/// Character.
class InitiativeFacet {
  static final dynamic _initcomp = 'INITCOMP'; // FormulaFactory.getFormulaFor("INITCOMP")

  dynamic formulaResolvingFacet;
  dynamic bonusCheckingFacet;

  /// Returns the Initiative value for the Player Character represented by the
  /// given CharID.
  int getInitiative(CharID id) {
    return (bonusCheckingFacet.getBonus(id, 'COMBAT', 'Initiative') as num).toInt()
        + (formulaResolvingFacet.resolve(id, _initcomp, '') as num).toInt();
  }

  void setFormulaResolvingFacet(dynamic formulaResolvingFacet) {
    this.formulaResolvingFacet = formulaResolvingFacet;
  }

  void setBonusCheckingFacet(dynamic bonusCheckingFacet) {
    this.bonusCheckingFacet = bonusCheckingFacet;
  }
}
