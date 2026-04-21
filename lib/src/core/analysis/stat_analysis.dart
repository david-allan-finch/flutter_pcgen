//
// Copyright 2009 (c) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.StatAnalysis
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';

abstract final class StatAnalysis {
  // Retrieve a correctly calculated attribute value where one or more types are excluded.
  static int getPartialStatFor(PlayerCharacter aPC, PCStat stat, bool useTemp, bool useEquip) {
    if (aPC.hasNonStatStat(stat)) return 10;
    if (!aPC.hasUnlockedStat(stat)) {
      final val = aPC.getLockedStat(stat);
      if (val != null) return val.toInt();
    }
    return aPC.getPartialStatFor(stat, useTemp, useEquip);
  }
}
