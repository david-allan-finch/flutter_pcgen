//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
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
// Translation of pcgen.core.EquipmentModifier
import 'bonus/bonus_obj.dart';
import 'pcobject.dart';
import 'special_property.dart';

/// Definition and game rules for an equipment modifier (EQMOD).
///
/// Translated from pcgen.core.EquipmentModifier (first ~80 lines +
/// additional key methods). Equipment modifiers are applied to equipment
/// and may add bonuses, special properties, and spell resistance.
final class EquipmentModifier extends PObject
    implements Comparable<Object> {
  // Variable parent for scoped variable resolution
  dynamic _variableParent;

  /// Returns all BonusObjs that are "active" for this modifier applied to
  /// [caller] equipment, checked against [aPC].
  ///
  /// [caller] is a dynamic reference to Equipment.
  /// [aPC] is a dynamic reference to PlayerCharacter.
  List<BonusObj> getActiveBonuses(dynamic caller, dynamic aPC) {
    final aList = <BonusObj>[];
    for (final bonus in getBonusListForEquipment(caller)) {
      bool passes = true;
      try {
        // PrereqHandler.passesAll(bonus, caller, aPC)
        if (bonus.hasPrerequisites()) {
          passes = false; // Simplified - full impl uses PrereqHandler
        }
      } catch (_) {}
      if (passes) {
        try {
          (aPC as dynamic).setApplied(bonus, true);
        } catch (_) {}
        aList.add(bonus);
      }
    }
    return aList;
  }

  /// Calling getBonusList with only a PlayerCharacter is prohibited for
  /// EquipmentModifier - bonuses must be resolved via Equipment.
  List<BonusObj> getBonusListForPC(dynamic pc) {
    throw UnsupportedError(
        'Cannot resolve bonuses on EqMod via PlayerCharacter - requires Equipment');
  }

  /// Get the bonus list for this modifier as applied to [equipment].
  ///
  /// Expands any %CHOICE placeholders using the associations on [equipment].
  List<BonusObj> getBonusListForEquipment(dynamic equipment) {
    // In the full implementation, this would call the parent PObject's
    // getBonusList(Equipment) which resolves through CDOMObject's list storage.
    // For now, return an empty list as a stub.
    final rawList = <BonusObj>[];
    return _expandChoiceBonuses(rawList, equipment);
  }

  List<BonusObj> _expandChoiceBonuses(
      List<BonusObj> bonusList, dynamic equipment) {
    final myBonusList = List<BonusObj>.from(bonusList);
    List<String> associations = [];
    try {
      associations = ((equipment as dynamic).getAssociationList(this) as List)
          .cast<String>();
    } catch (_) {}

    for (int i = myBonusList.length - 1; i >= 0; i--) {
      final aBonus = myBonusList[i];
      final aString = aBonus.toString();
      final idx = aString.indexOf('%CHOICE');
      if (idx >= 0) {
        for (final assoc in associations) {
          final newString = aString.replaceAll('%CHOICE', assoc);
          final newBonus = _bonusObjFromString(newString);
          if (newBonus != null) {
            myBonusList.add(newBonus);
          }
        }
        myBonusList.removeAt(i);
      }
    }
    return myBonusList;
  }

  /// Does this Equipment Modifier add [type] to the equipment it is applied to?
  bool isIType(String type) {
    // Checks ITEM_TYPES list key - simplified
    try {
      return isType(type);
    } catch (_) {
      return false;
    }
  }

  /// Returns a list of resolved special property strings for [caller] and [pc].
  List<String> getSpecialProperties(dynamic caller, dynamic pc) {
    final retList = <String>[];
    List<SpecialProperty> spList = [];
    try {
      // Full impl: getSafeListFor(ListKey.getConstant<SpecialProperty>('SPECIAL_PROPERTIES'))
      spList = [];
    } catch (_) {}

    List<String> associations = [];
    try {
      associations = ((caller as dynamic).getAssociationList(this) as List)
          .cast<String>();
    } catch (_) {}

    for (final sp in spList) {
      String propName = '';
      try {
        propName = sp.getParsedText(pc, caller, this);
      } catch (_) {
        propName = sp.getText();
      }
      for (final assoc in associations) {
        propName = propName.replaceFirst('%CHOICE', assoc);
      }
      if (propName.isNotEmpty) {
        retList.add(propName);
      }
    }
    return retList;
  }

  /// Calculate the bonus to [aType]/[aName] for this modifier applied to [obj].
  double bonusTo(dynamic aPC, String aType, String aName, dynamic obj) {
    // BonusCalc.bonusTo deferred to full implementation
    return 0.0;
  }

  /// Get the spell resistance value for this modifier.
  int getSR(dynamic parent, dynamic aPC) {
    // Simplified - ObjectKey.SR lookup deferred
    return 0;
  }

  /// Returns the display type string (dot-joined types).
  String getDisplayType() {
    return getTrueTypeList(true).map((t) => t.toString()).join('.');
  }

  /// Returns the local scope name for variable resolution.
  String getLocalScopeName() => 'PC.EQUIPMENT.PART';

  void setVariableParent(dynamic vs) {
    _variableParent = vs;
  }

  dynamic getVariableParent() => _variableParent;

  @override
  int compareTo(Object o) {
    if (o is EquipmentModifier) {
      return getKeyName().compareTo(o.getKeyName());
    }
    return getKeyName().compareTo(o.toString());
  }

  @override
  EquipmentModifier clone() {
    final aObj = EquipmentModifier();
    aObj.setDisplayName(getDisplayName());
    aObj.setKeyName(getKeyName());
    return aObj;
  }

  @override
  String toString() => getDisplayName();
}

// Stub factory for creating a BonusObj from a string during %CHOICE expansion.
// Full implementation would call Bonus.newBonus(context, bonusString).
BonusObj? _bonusObjFromString(String bonusString) => null;
