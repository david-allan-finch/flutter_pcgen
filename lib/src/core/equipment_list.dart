//
// Copyright 2003 (C) Jonas Karlsson <jujutsunerd@users.sourceforge.net>
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
// Translation of pcgen.core.EquipmentList
// EquipmentList.dart
// Translated from pcgen/core/EquipmentList.java

import 'globals.dart';
import 'equipment.dart';
import 'equipment_modifier.dart';
import 'player_character.dart';
import 'size_adjustment.dart';
import 'utils/core_utility.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/enumeration/type.dart';
import 'prereq/prereq_handler.dart';

/// Equipment-related utility methods extracted from Globals.
class EquipmentList {
  EquipmentList._();

  /// Return the equipment that has the passed-in name.
  static Equipment? getEquipmentFromName(String baseName, PlayerCharacter aPC) {
    final List<String> modList = [];
    final List<String> namList = [];
    final List<String> sizList = [];
    Equipment? eq;
    String aName = baseName;
    int i = aName.indexOf('(');

    // Remove all modifiers from item name and split into size/non-size lists
    if (i >= 0) {
      final String inside = aName.substring(i + 1);
      final List<String> tokens = inside.split(RegExp(r'[/)]'));
      for (final String cString in tokens) {
        if (cString.isEmpty) continue;
        final SizeAdjustment? sa = Globals.getContext()
            .getReferenceContext()
            .silentlyGetConstructedCDOMObject(SizeAdjustment, cString);
        if (sa != null) {
          sizList.add(cString);
        } else {
          if (cString.toLowerCase() == 'mighty composite') {
            modList.add('Mighty');
            modList.add('Composite');
          } else {
            modList.add(cString);
          }
        }
      }
      aName = aName.substring(0, i).trim();
    }

    // Separate non-size descriptors into modifier / non-modifier lists
    if (i >= 0) {
      for (int idx = modList.length - 1; idx >= 0; --idx) {
        final String namePart = modList[idx];
        if (_getModifierNamed(namePart) == null) {
          namList.insert(0, namePart);
          modList.removeAt(idx);
        }
      }
    }

    // Look for magic/mighty bonuses
    List<int>? bonuses;
    int bonusCount = 0;
    i = aName.indexOf('+');

    if (i >= 0) {
      final List<String> bonusTokens =
          aName.substring(i).split('/');
      bonusCount = bonusTokens.length;
      bonuses = List<int>.filled(bonusCount, 0);
      for (int idx = 0; idx < bonusTokens.length; idx++) {
        bonuses[idx] = _deltaIntDecode(bonusTokens[idx]);
      }
      aName = aName.substring(0, i).trim();

      if (bonusCount > 0) {
        for (int idx1 = 0; idx1 < namList.length; ++idx1) {
          String aString = namList[idx1];
          if (aString.toLowerCase() == 'mighty') {
            aString = '${_deltaToString(bonuses[bonusCount - 1])} $aString';
            namList[idx1] = aString;
            bonusCount -= 1;
          }
        }
      }
    }

    String omitString = '';
    String bonusString = '';

    outer:
    while (true) {
      final String eqName = aName + bonusString;
      eq = _findEquipment(eqName, null, namList, sizList, omitString);
      if (eq != null) {
        if (sizList.length > 1) sizList.removeAt(0);
        break;
      }

      eq = _findEquipment(eqName, namList, null, sizList, omitString);
      if (eq != null) {
        if (sizList.length > 1) sizList.removeAt(0);
        break;
      }

      eq = _findEquipment(eqName, namList, null, null, omitString);
      if (eq != null) break;

      if (sizList.length == 1) {
        eq = _findEquipment(eqName, sizList, namList, null, omitString);
        eq ??= _findEquipment(eqName, namList, sizList, null, omitString);
        if (eq != null) {
          sizList.clear();
          break;
        }
      }

      if (baseName.contains('Thrown') && omitString.isEmpty) {
        omitString = 'Thrown';
        continue;
      }

      if (bonusCount > 0 && bonuses != null && bonusString.isEmpty) {
        omitString = '';
        bonusString = ' ${_deltaToString(bonuses[0])}';
        continue;
      }

      break;
    }

    if (eq != null) {
      bool bModified = false;
      bool bError = false;
      eq = eq.clone();

      for (final String namePart in modList) {
        final EquipmentModifier? eqMod = _getQualifiedModifierNamed(namePart, eq!);
        if (eqMod != null) {
          eq.addEqModifier(eqMod, true, aPC);
          if ((eqMod.getSafe(ObjectKey.assignToAll) as bool? ?? false) && eq.isDouble()) {
            eq.addEqModifier(eqMod, false, aPC);
            bModified = true;
          }
        } else {
          // log: Could not find a qualified modifier named: $namePart for ${eq.getName()}:${eq.typeList()}
          bError = true;
        }
      }

      if (bError) return null;

      if (sizList.isNotEmpty) {
        final SizeAdjustment? sa = Globals.getContext()
            .getReferenceContext()
            .silentlyGetConstructedCDOMObject(SizeAdjustment, sizList[0]);
        eq!.resizeItem(aPC, sa);
        bModified = true;
        if (sizList.length > 1) {
          // log: Too many sizes in item name, used only 1st of: $sizList
        }
      }

      if (bModified) {
        final String sKeyName = eq!.nameItemFromModifiers(aPC);
        Equipment? equip = Globals.getContext()
            .getReferenceContext()
            .silentlyGetConstructedCDOMObject(Equipment, sKeyName);
        if (equip == null) {
          Globals.getContext().getReferenceContext().importObject(eq);
        } else {
          eq = equip;
        }
      }
    }

    return eq;
  }

  /// Get all equipment matching the desired types minus the excluded types.
  static List<Equipment> getEquipmentOfType(String desiredTypes, String excludedTypes) {
    final List<String> desiredTypeList = CoreUtility.split(desiredTypes, '.');
    final List<String> excludedTypeList = CoreUtility.split(excludedTypes, '.');
    final List<Equipment> typeList = [];

    if (desiredTypeList.isNotEmpty) {
      for (final Equipment eq in Globals.getContext()
          .getReferenceContext()
          .getConstructedCDOMObjects(Equipment)) {
        bool addIt = true;

        for (final String type in desiredTypeList) {
          if (!eq.isType(type)) {
            addIt = false;
            break;
          }
        }

        if (addIt && excludedTypeList.isNotEmpty) {
          for (final String type in excludedTypeList) {
            if (eq.isType(type)) {
              addIt = false;
              break;
            }
          }
        }

        if (addIt) typeList.add(eq);
      }
    }

    return typeList;
  }

  static EquipmentModifier? _getModifierNamed(String aName) {
    for (final EquipmentModifier eqMod in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(EquipmentModifier)) {
      if (eqMod.getDisplayName() == aName) return eqMod;
    }
    return null;
  }

  static EquipmentModifier? _getQualifiedModifierNamed(
      String aName, Equipment eq) {
    for (final EquipmentModifier eqMod in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(EquipmentModifier)) {
      if (!eqMod.getDisplayName().startsWith(aName)) continue;
      final List<String> types = eq.typeList();
      for (final String t in types) {
        if (eqMod.isType(t) && PrereqHandler.passesAll(eqMod, eq, null)) {
          return eqMod;
        }
      }
    }
    return null;
  }

  static void _appendNameParts(
      List<String> nameList, String omitString, StringBuffer newName) {
    for (final String namePart in nameList) {
      if (omitString.isNotEmpty && namePart == omitString) continue;
      if (newName.length > 2) newName.write('/');
      newName.write(namePart);
    }
  }

  static void _createItemWithMod(Equipment? eq, EquipmentModifier eqMod,
      PlayerCharacter aPC, String choice, dynamic equipChoice) {
    _createItem(eq, eqMod, null, aPC, choice, equipChoice);
  }

  static void _createItem(Equipment? eq, EquipmentModifier? eqMod,
      SizeAdjustment? sa, PlayerCharacter aPC, String choice, dynamic equipChoice) {
    if (eq == null) return;

    try {
      if (!(eq.getSafe(ObjectKey.modControl) as dynamic)?.getModifiersAllowed() == true ||
          (eq.isArmor() &&
              (eq.getACMod(aPC) == 0) &&
              (eqMod != null &&
                  eqMod.getDisplayName().toLowerCase() != 'masterwork'))) {
        return;
      }

      eq = eq.clone();
      if (eq == null) {
        // log: could not clone item
        return;
      }

      if (eqMod != null) {
        eq.addEqModifier(eqMod, true, aPC, choice, equipChoice);
        if (eq.isWeapon() && eq.isDouble()) {
          eq.addEqModifier(eqMod, false, aPC, choice, equipChoice);
        }
      }

      if (sa != null) {
        eq.resizeItem(aPC, sa);
      }

      final String sKeyName = eq.nameItemFromModifiers(aPC);
      final Equipment? eqExists = Globals.getContext()
          .getReferenceContext()
          .silentlyGetConstructedCDOMObject(Equipment, sKeyName);
      if (eqExists != null) return;

      final Type newType = Type.custom;
      if (!eq.isType(newType.toString())) {
        eq.addType(newType);
      }

      Globals.getContext().getReferenceContext().importObject(eq);
    } catch (e) {
      // log: createItem: exception: ${eq?.getName()}
    }
  }

  static Equipment? _findEquipment(
    String aName,
    List<String>? preNameList,
    List<String>? postNameList,
    List<String>? sizList,
    String omitString,
  ) {
    final StringBuffer newName = StringBuffer(' (');

    if (preNameList != null) {
      _appendNameParts(preNameList, omitString, newName);
    }

    if (sizList != null && sizList.length > 1) {
      newName.write(sizList[0]);
    }

    if (postNameList != null) {
      _appendNameParts(postNameList, omitString, newName);
    }

    if (newName.length == 2) {
      // nothing appended after ' ('
      return Globals.getContext()
          .getReferenceContext()
          .silentlyGetConstructedCDOMObject(Equipment, aName);
    } else {
      newName.write(')');
      return Globals.getContext()
          .getReferenceContext()
          .silentlyGetConstructedCDOMObject(Equipment, '$aName$newName');
    }
  }

  /// Decode a signed integer string like "+3" or "-1".
  static int _deltaIntDecode(String s) {
    s = s.trim();
    return int.tryParse(s) ?? 0;
  }

  static String _deltaToString(int val) {
    return val >= 0 ? '+$val' : '$val';
  }
}
