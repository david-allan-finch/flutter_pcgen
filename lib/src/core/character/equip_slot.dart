import '../globals.dart';

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
