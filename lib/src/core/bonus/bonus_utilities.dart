//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
// Copyright 2005 (C) Tom Parker <thpr@sourceforge.net>
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
// Refactored out of PObject July 22, 2005
//
// Translation of pcgen.core.bonus.BonusUtilities
import 'bonus_obj.dart';

// Utility methods for working with BonusObj collections.
abstract final class BonusUtilities {
  // Returns all bonuses in the list that match the given type and name.
  static List<BonusObj> getBonusFromList(Iterable<BonusObj>? bonusList, String aType, String aName) {
    final aList = <BonusObj>[];
    if (bonusList == null) return aList;
    for (final aBonus in bonusList) {
      if (aBonus.getTypeOfBonus() != aType) continue;
      final infoList = aBonus.getBonusInfoList();
      if (infoList.length > 1) {
        for (final aBI in aBonus.getBonusInfo().split(',')) {
          if (aBI == aName) aList.add(aBonus);
        }
      } else if (aBonus.getBonusInfo() == aName) {
        aList.add(aBonus);
      }
    }
    return aList;
  }
}
