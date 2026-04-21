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
// Translation of pcgen.core.kit.KitGear
import 'package:flutter_pcgen/src/base/formula/formula.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/helper/eq_mod_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/size_adjustment.dart';
import 'base_kit.dart';

// Kit task that adds equipment (gear) to a PC.
final class KitGear extends BaseKit {
  Formula? quantity;
  int? maxCost;
  CDOMReference<Equipment>? equip;
  List<EqModRef>? mods;
  String? theLocationStr;
  bool? sizeToPC;
  CDOMSingleRef<SizeAdjustment>? size;

  // Transient state (not cloned)
  Formula? _actingQuantity;
  int? _actingCost;
  List<EqModRef>? _actingMods;
  String? _actingLocation;
  SizeAdjustment? _actingSize;

  Equipment? _theEquipment;
  int _theQty = 0;
  String _theLocation = '';
  double _theCost = 0.0;

  void setLocation(String aLocation) { theLocationStr = aLocation; }
  String? getLocation() => theLocationStr;

  void setQuantity(Formula f) { quantity = f; }
  Formula? getQuantity() => quantity;

  void setMaxCost(int cost) { maxCost = cost; }
  int? getMaxCost() => maxCost;

  void setEquipment(CDOMReference<Equipment> ref) { equip = ref; }
  CDOMReference<Equipment>? getEquipment() => equip;

  void setMods(List<EqModRef> modList) { mods = modList; }
  List<EqModRef>? getMods() => mods;

  void setSizeToPC(bool flag) { sizeToPC = flag; }
  bool? getSizeToPC() => sizeToPC;

  void setSize(CDOMSingleRef<SizeAdjustment> sizeRef) { size = sizeRef; }
  CDOMSingleRef<SizeAdjustment>? getSize() => size;

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _actingQuantity = quantity;
    _actingCost = maxCost;
    _actingMods = mods == null ? null : List.of(mods!);
    _actingLocation = theLocationStr;
    _actingSize = size?.get();

    _theEquipment = null;
    _theQty = 0;
    _theLocation = '';
    _theCost = 0.0;

    if (equip == null) return false;

    final eqList = equip!.getContainedObjects().whereType<Equipment>().toList();
    if (_actingCost != null) {
      eqList.removeWhere((eq) => eq.getCost(aPC) > _actingCost!);
    }

    if (eqList.isEmpty) {
      warnings.add('GEAR: No equipment found for $equip');
      return false;
    }

    _theEquipment = eqList.length == 1 ? eqList[0] : eqList[0];
    _theEquipment = _theEquipment!.clone();

    final qty = _actingQuantity?.resolve(aPC, '').toInt() ?? 1;
    _theQty = qty;

    _theLocation = _actingLocation ?? '';
    _theCost = _theEquipment!.getCost(aPC) * qty * aKit.getBuyRate(aPC) / 100.0;

    final pcGold = aPC.getGold();
    if (_theCost > pcGold) {
      warnings.add('GEAR: Not enough gold to purchase ${_theEquipment!.getDisplayName()}');
      return false;
    }

    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    if (_theEquipment == null) return;
    aPC.addEquipment(_theEquipment!);
    if (_theCost > 0) aPC.setGold(aPC.getGold() - _theCost);
    if (_theLocation.isNotEmpty) {
      aPC.setEquipmentLocation(_theEquipment!, _theLocation);
    }
  }

  @override
  String getObjectName() => 'Gear';

  @override
  String toString() {
    final sb = StringBuffer();
    if (quantity != null && quantity.toString() != '1') {
      sb.write('${quantity}x');
    }
    sb.write(equip?.getLSTformat(false) ?? 'null');
    if (mods != null && mods!.isNotEmpty) {
      sb.write(' (');
      sb.write(mods!.map((m) => m.getRef().getLSTformat(false)).join('/'));
      sb.write(')');
    }
    return sb.toString();
  }
}
