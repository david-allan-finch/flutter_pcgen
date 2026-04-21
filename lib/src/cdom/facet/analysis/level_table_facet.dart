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

/// LevelTableFacet stores the Experience Point table used to identify how many
/// experience points are required at a certain character level.
class LevelTableFacet {
  dynamic xpTableFacet;
  dynamic resolveFacet;

  /// Returns the (minimum) number of total Experience Points needed for a
  /// given level.
  int minXPForLevel(int level, CharID id) {
    final info = xpTableFacet.getLevelInfo(id, level);
    if (info != null) {
      // FormulaFactory.getFormulaFor(info.getMinXPVariable(level))
      final f = info.getMinXPVariable(level) as String;
      return (resolveFacet.resolve(id, f, '') as num).toInt();
    }

    // TODO: Should this be a warning/error?
    return 0;
  }

  void setResolveFacet(dynamic resolveFacet) {
    this.resolveFacet = resolveFacet;
  }

  void setXpTableFacet(dynamic xpTableFacet) {
    this.xpTableFacet = xpTableFacet;
  }
}
