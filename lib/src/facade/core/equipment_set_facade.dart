// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.EquipmentSetFacade

abstract interface class EquipmentSetFacade {
  bool isContainer(dynamic equipment);
  dynamic getEquippedItems();
  dynamic addEquipment(dynamic node, dynamic equipment, int quantity,
      [dynamic beforeNode]);
  dynamic removeEquipment(dynamic node, int quantity);
  void removeAllEquipment();
  List<dynamic> getNodes();
  int getQuantity(dynamic node);
  String getLocation(dynamic node);
  bool canEquip(dynamic node, dynamic equipment);
  dynamic getNameRef();
  void setName(String name);
  void addEquipmentTreeListener(dynamic listener);
  void removeEquipmentTreeListener(dynamic listener);
  String getPreferredLoc(dynamic equipment);
  String getLocationForEquip(dynamic equip);
}
