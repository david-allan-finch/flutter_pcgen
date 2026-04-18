// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.EquipmentBuilderFacade

enum EquipmentHead { primary, secondary }

abstract interface class EquipmentBuilderFacade {
  bool addModToEquipment(dynamic modifier, EquipmentHead head);
  bool removeModFromEquipment(dynamic modifier, EquipmentHead head);
  bool setName(String name);
  bool setSProp(String sprop);
  bool setCost(String newCost);
  bool setWeight(String newWeight);
  bool setDamage(String newValue);
  List<dynamic> getAvailList(EquipmentHead head);
  List<dynamic> getSelectedList(EquipmentHead head);
  dynamic getEquipment();
  bool isResizable();
  void setSize(dynamic newSize);
  dynamic getSizeRef();
  Set<EquipmentHead> getEquipmentHeads();
  String getBaseItemName();
  bool isWeapon();
  String getDamage();
}
