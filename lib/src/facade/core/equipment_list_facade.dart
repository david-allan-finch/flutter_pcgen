// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.EquipmentListFacade

abstract interface class EquipmentListFacade {
  int getQuantity(dynamic equipment);
  void addEquipmentListListener(dynamic listener);
  void removeEquipmentListListener(dynamic listener);
  void modifyElement(dynamic equipment);
}
