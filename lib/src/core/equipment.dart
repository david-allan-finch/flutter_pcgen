//
// Copyright 2001 (C) Bryan McRoberts <merton.monk@codemonkeypublishing.com>
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
// Translation of pcgen.core.Equipment

import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

// ---------------------------------------------------------------------------
// Equipment location enum
// ---------------------------------------------------------------------------

enum EquipmentLocation {
  notCarried,
  carried,
  equipped,
  primaryHand,
  secondaryHand,
  bothHands,
  twoWeapons,
  shield,
  naturalPrimary,
  naturalSecondary,
  unarmed,
  doubleWeapon,
}

// ---------------------------------------------------------------------------
// Equipment
// ---------------------------------------------------------------------------

/// Represents a piece of equipment (weapon, armor, item) for a PC.
class Equipment extends PObject {
  // Core numeric state
  double _qty = 1.0;
  int _outputIndex = 0;
  int _outputSubindex = 0;
  bool _isEquipped = false;
  bool _isAutomatic = false;
  EquipmentLocation _eqLocation = EquipmentLocation.notCarried;
  double _weight = 0.0;
  double _costMod = 0.0;
  double _numberCarried = 0.0;
  int _numberEquipped = 0;
  String? _note;
  String? _appliedName;
  String? _modifiedName;
  String? _containerCapacityString;

  Equipment? _parent;
  List<dynamic> _eqModifiers = [];       // primary head
  List<dynamic> _eqModifiersHead2 = [];  // secondary head (double weapons)

  // ---------------------------------------------------------------------------
  // Quantity
  // ---------------------------------------------------------------------------

  double getQty() => _qty;
  void setQty(double qty) { _qty = qty; }
  void setNumberCarried(double n) { _numberCarried = n; }
  double getNumberCarried() => _numberCarried;

  // ---------------------------------------------------------------------------
  // Output ordering
  // ---------------------------------------------------------------------------

  int getOutputIndex() => _outputIndex;
  void setOutputIndex(int i) { _outputIndex = i; }

  int getOutputSubindex() => _outputSubindex;
  void setOutputSubindex(int i) { _outputSubindex = i; }

  // ---------------------------------------------------------------------------
  // Equipped / location
  // ---------------------------------------------------------------------------

  bool isEquipped() => _isEquipped;
  void setIsEquipped(bool equipped, [dynamic pc]) { _isEquipped = equipped; }

  EquipmentLocation getLocation() => _eqLocation;
  void setLocation(EquipmentLocation loc) { _eqLocation = loc; }

  int getNumberEquipped() => _numberEquipped;
  void setNumberEquipped(int n) { _numberEquipped = n; }

  // ---------------------------------------------------------------------------
  // Physical properties
  // ---------------------------------------------------------------------------

  double getWeightAsDouble() => _weight;
  void setWeight(double w) { _weight = w; }

  double getCostAsDouble([dynamic pc]) => _costMod;
  void setCostMod(double c) { _costMod = c; }

  // ---------------------------------------------------------------------------
  // Names
  // ---------------------------------------------------------------------------

  @override
  String getName() => _modifiedName ?? getKeyName();

  /// Display name: prefer OUTPUTNAME if set, otherwise use the display name
  /// set by setName(). Falls back to key name if still empty.
  @override
  String getDisplayName() {
    final output = getString(StringKey.outputName);
    if (output != null && output.isNotEmpty) return output;
    final dn = super.getDisplayName();
    if (dn.isNotEmpty) return dn;
    return getKeyName();
  }

  @override
  void setName(String name) {
    setDisplayName(name); // keep _displayName in sync
    setKeyName(name);
  }

  void setModifiedName(String name) { _modifiedName = name; }

  String? getAppliedName() => _appliedName;
  void setAppliedName(String name) { _appliedName = name; }

  String getBaseItemName() => getKeyName();
  String getBaseItemKeyName() => getKeyName();

  // ---------------------------------------------------------------------------
  // Note
  // ---------------------------------------------------------------------------

  String? getNote() => _note;
  void setNote(String note) { _note = note; }

  // ---------------------------------------------------------------------------
  // Parent / container
  // ---------------------------------------------------------------------------

  Equipment? getParent() => _parent;
  void setParent(Equipment? parent) { _parent = parent; }

  bool isContainer() =>
      getSafeInt(IntegerKey.containerReduceWeight) > 0 ||
      _containerCapacityString != null;

  String? getContainerCapacityString() => _containerCapacityString;
  void setContainerCapacityString(String s) { _containerCapacityString = s; }

  // ---------------------------------------------------------------------------
  // Equipment modifiers
  // ---------------------------------------------------------------------------

  List<dynamic> getEqModifierList(bool primary) =>
      primary
          ? List.unmodifiable(_eqModifiers)
          : List.unmodifiable(_eqModifiersHead2);

  void addToEqModifierList(dynamic eqMod, bool primary) {
    if (primary) _eqModifiers.add(eqMod); else _eqModifiersHead2.add(eqMod);
  }

  dynamic getEqModifierKeyed(dynamic eqModKey, bool primary) {
    final list = primary ? _eqModifiers : _eqModifiersHead2;
    for (final mod in list) {
      if ((mod as dynamic).getKeyName() == eqModKey?.toString()) return mod;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Type checking — delegates to TYPE list
  // ---------------------------------------------------------------------------

  bool isType(String aType, [bool primary = true]) {
    final types = getSafeListFor<Type>(ListKey.getConstant<Type>('TYPE'));
    return types.any((t) => t.toString().equalsIgnoreCase(aType));
  }

  bool isEitherType(String aType) => isType(aType);
  bool typeStringContains(String aType) => isType(aType);

  bool isAmmunition()      => isType('AMMUNITION');
  bool isArmor()           => isType('ARMOR');
  bool isDouble()          => isType('DOUBLE');
  bool isExtra()           => isType('EXTRA');
  bool isHeavy()           => isType('HEAVY');
  bool isMedium()          => isType('MEDIUM');
  bool isLight()           => isType('LIGHT');
  bool isMagic()           => isType('MAGIC');
  bool isMelee()           => isType('MELEE');
  bool isMonk()            => isType('MONK');
  bool isNatural()         => isType('NATURAL');
  bool isPrimaryNaturalWeapon() => isType('NATURAL') && !isType('SECONDARY');
  bool isRanged()          => isType('RANGED');
  bool isShield()          => isType('SHIELD');
  bool isThrown()          => isType('THROWN');
  bool isUnarmed()         => isType('UNARMED');
  bool isWeapon()          => isType('WEAPON');
  bool isProjectile()      => isType('PROJECTILE');
  bool isAutomatic()       => _isAutomatic;
  void setAutomatic(bool b) { _isAutomatic = b; }
  bool isSellAsCash()      => isType('SELLASCASH');
  bool isMasterwork()      => isType('MASTERWORK');
  bool isNaturalWeapon()   => isNatural();

  // ---------------------------------------------------------------------------
  // Statistical properties
  // ---------------------------------------------------------------------------

  int getSlot()         => getSafeInt(IntegerKey.slots);
  int getPlus()         => getSafeInt(IntegerKey.plus);
  int acCheck()         => getSafeInt(IntegerKey.acCheck);
  int spellFailure()    => getSafeInt(IntegerKey.spellFailure);
  int getReach()        => getSafeInt(IntegerKey.reach);
  int getRange()        => getSafeInt(IntegerKey.range);
  int getHands()        => getSafeInt(IntegerKey.hands);
  int getMaxCharges()   => getSafeInt(IntegerKey.maxCharges);
  int getMinCharges()   => getSafeInt(IntegerKey.minCharges);
  int getNumAttacks()   => 1;

  String getWieldName() {
    final wield = getSafeObject(ObjectKey.getConstant<dynamic>('WIELD'));
    return wield?.toString() ?? '';
  }

  String getArmorType() {
    final at = getSafeObject(ObjectKey.getConstant<dynamic>('ARMOR_TYPE'));
    return at?.toString() ?? '';
  }

  bool isAutoSize() => getKeyName().startsWith(Constants.autoResizePrefix);

  /// Returns all active bonus objects for this equipment given [pc].
  List<dynamic> getActiveBonuses(dynamic pc) {
    // TODO: filter raw bonus list through prerequisite checks
    return getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('BONUS'));
  }

  String getInterestingDisplayString([dynamic pc]) {
    // TODO: build modifiers string
    return getDisplayName();
  }

  String getItemNameFromModifiers() {
    // TODO: reconstruct item name from eqMod names
    return getName();
  }

  // ---------------------------------------------------------------------------
  // Clone
  // ---------------------------------------------------------------------------

  @override
  Equipment clone() {
    final copy = Equipment();
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    copy._qty = _qty;
    copy._weight = _weight;
    copy._costMod = _costMod;
    copy._eqLocation = _eqLocation;
    copy._isEquipped = _isEquipped;
    copy._modifiedName = _modifiedName;
    copy._note = _note;
    return copy;
  }

  @override
  String toString() => getDisplayName();
}

// ---------------------------------------------------------------------------
// String extension helper (case-insensitive compare)
// ---------------------------------------------------------------------------

extension _StringCI on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase() == other.toLowerCase();
}
