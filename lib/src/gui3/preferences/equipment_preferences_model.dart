//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.preferences.EquipmentPreferencesModel

import 'package:flutter/foundation.dart';

/// Model for the Equipment preferences panel.
class EquipmentPreferencesModel extends ChangeNotifier {
  bool _autoResize = true;
  bool _masterworkMaxDex = false;
  bool _ignoreCostForAutoEquip = false;
  String _potionMaxLevel = '3';
  String _wandMaxLevel = '4';
  bool _allowProfWithArmorAsShield = false;
  bool _simpleEquipmentMastery = false;

  bool get autoResize => _autoResize;
  bool get masterworkMaxDex => _masterworkMaxDex;
  bool get ignoreCostForAutoEquip => _ignoreCostForAutoEquip;
  String get potionMaxLevel => _potionMaxLevel;
  String get wandMaxLevel => _wandMaxLevel;
  bool get allowProfWithArmorAsShield => _allowProfWithArmorAsShield;
  bool get simpleEquipmentMastery => _simpleEquipmentMastery;

  void setAutoResize(bool v) { _autoResize = v; notifyListeners(); }
  void setMasterworkMaxDex(bool v) { _masterworkMaxDex = v; notifyListeners(); }
  void setIgnoreCostForAutoEquip(bool v) { _ignoreCostForAutoEquip = v; notifyListeners(); }
  void setPotionMaxLevel(String v) { _potionMaxLevel = v; notifyListeners(); }
  void setWandMaxLevel(String v) { _wandMaxLevel = v; notifyListeners(); }
  void setAllowProfWithArmorAsShield(bool v) { _allowProfWithArmorAsShield = v; notifyListeners(); }
  void setSimpleEquipmentMastery(bool v) { _simpleEquipmentMastery = v; notifyListeners(); }
}
