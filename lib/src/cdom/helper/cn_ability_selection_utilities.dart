//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.CNAbilitySelectionUtilities
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'cn_ability_selection.dart';

// Utility methods for checking whether two CNAbilitySelections can coexist on a PC.
final class CNAbilitySelectionUtilities {
  CNAbilitySelectionUtilities._();

  static bool canCoExist(CNAbilitySelection cnas1, CNAbilitySelection cnas2) {
    final cna = cnas1.getCNAbility();
    final a = cna.getAbility();
    final ocna = cnas2.getCNAbility();

    if (ocna.getAbilityCategory().getParentCategory() !=
        cna.getAbilityCategory().getParentCategory()) {
      return true;
    }
    if (ocna.getAbility() != a) return true;

    if (!a.getSafeObject(ObjectKey.multipleAllowed)) return false;
    if (a.getSafeObject(ObjectKey.stacks)) return true;

    return cnas1.getSelection() != cnas2.getSelection();
  }
}
