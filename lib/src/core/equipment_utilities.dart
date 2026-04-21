//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
//  Refactored from PlayerCharacter, created on April 21, 2001, 2:15 PM
//
// Translation of pcgen.core.EquipmentUtilities
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'equipment.dart';

final class EquipmentUtilities {
  EquipmentUtilities._();

  // Returns all equipment items that are NOT of the given type.
  static List<Equipment> removeEqType(List<Equipment> aList, String type) {
    final result = <Equipment>[];
    for (final eq in aList) {
      if ('CONTAINED'.toLowerCase() == type.toLowerCase() &&
          eq.getParent() != null) {
        continue;
      }
      if (!eq.typeStringContains(type)) result.add(eq);
    }
    return result;
  }

  // Returns only equipment items that ARE of the given type.
  static List<Equipment> removeNotEqType(List<Equipment> aList, String aString) {
    return aList.where((eq) => eq.typeStringContains(aString)).toList();
  }

  // Appends aString to aName using parenthesis notation.
  static String appendToName(String aName, String aString) {
    final buf = StringBuffer(aName);
    final iLen = buf.length - 1;
    // StringBuffer doesn't allow in-place char replacement easily
    final s = buf.toString();
    if (s[iLen] == ')') {
      return '${s.substring(0, iLen)}/$aString)';
    } else {
      return '$s ($aString)';
    }
  }

  // Finds equipment in aList whose key (or base item key chain) matches baseKey.
  static Equipment? findEquipmentByBaseKey(
      List<Equipment> aList, String baseKey) {
    for (final equipment in aList) {
      Equipment? target = equipment;
      while (target != null) {
        if (target.getKeyName().toLowerCase() == baseKey.toLowerCase()) {
          return equipment;
        }
        final baseRef = target.getObject(ObjectKey.baseItem);
        target = baseRef == null ? null : (baseRef as dynamic)?.get();
      }
    }
    return null;
  }
}
