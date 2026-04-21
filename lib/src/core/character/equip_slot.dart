//
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
// Translation of pcgen.core.character.EquipSlot
import 'package:flutter_pcgen/src/core/globals.dart';

// Defines an equipment slot (Neck, Body, Fingers, etc.) and what it can hold.
// Format: EQSLOT:Neck  CONTAINS:PERIAPT,AMULET=1  NUMBER:HEAD
final class EquipSlot {
  String slotName = '';
  Set<String> containEqList = {};
  String slotNumType = ''; // body structure name
  int containNum = 1;

  bool canContainType(String aTypeList) {
    for (final part in aTypeList.split('.')) {
      for (final allowed in containEqList) {
        if (part.toLowerCase() == allowed.toLowerCase()) return true;
      }
    }
    return false;
  }

  void addContainedType(String type) => containEqList.add(type);

  int getSlotCount() {
    final multi = Globals.getEquipSlotTypeCount(slotNumType);
    return multi * containNum;
  }

  String getBodyStructureName() => slotNumType;

  EquipSlot clone() => EquipSlot()
    ..slotName = slotName
    ..containEqList = Set.of(containEqList)
    ..slotNumType = slotNumType
    ..containNum = containNum;

  @override
  String toString() => slotName;
}
