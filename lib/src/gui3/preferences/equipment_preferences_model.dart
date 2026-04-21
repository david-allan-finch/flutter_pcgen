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
