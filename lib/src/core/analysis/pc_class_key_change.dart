//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.PCClassKeyChange
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';

// Renames class-references in variables and bonuses when a PCClass key changes.
final class PCClassKeyChange {
  PCClassKeyChange._();

  static void changeReferences(String oldClass, PCClass pcc) {
    final newClass = pcc.getKeyName();
    if (oldClass == newClass) return;

    _renameVariables(oldClass, pcc, newClass);
    _renameBonusTarget(pcc, oldClass, newClass);

    for (final pcl in pcc.getOriginalClassLevelCollection()) {
      _renameVariables(oldClass, pcl, newClass);
      _renameBonusTarget(pcl, oldClass, newClass);
    }
  }

  static void _renameVariables(String oldClass, CDOMObject pcc, String newClass) {
    for (final vk in pcc.getVariableKeys()) {
      final current = pcc.get(vk).toString();
      pcc.put(vk, current.replaceAll('=$oldClass', '=$newClass'));
    }
  }

  static void _renameBonusTarget(CDOMObject cdo, String oldClass, String newClass) {
    final bonusList = cdo.getListFor(ListKey.bonus);
    if (bonusList == null) return;

    for (final bonusObj in List.from(bonusList)) {
      final bonus = bonusObj.toString();
      int offs = -1;
      for (;;) {
        offs = bonus.indexOf('=$oldClass', offs + 1);
        if (offs < 0) break;
        final newBonus = bonus.substring(0, offs + 1) +
            newClass +
            bonus.substring(offs + oldClass.length + 1);
        // Bonus.newBonus — stub; add to list if non-null
        cdo.addToListFor(ListKey.bonus, newBonus);
        cdo.removeFromListFor(ListKey.bonus, bonusObj);
      }
    }
  }
}
