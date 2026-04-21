// Translation of pcgen.gui2.tabs.equip.EquipmentSelection

/// Represents a selection of equipment items to be added/removed from an equipment set.
class EquipmentSelection {
  final String equipmentSetName;
  final List<EquipmentItem> items;

  const EquipmentSelection({
    required this.equipmentSetName,
    required this.items,
  });
}

class EquipmentItem {
  final String name;
  final int quantity;
  final String? location;

  const EquipmentItem({
    required this.name,
    this.quantity = 1,
    this.location,
  });
}
