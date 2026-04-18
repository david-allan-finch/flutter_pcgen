// Where equipment is worn/carried by a character.
enum EquipmentLocation {
  equippedNeither,
  equippedPrimary,
  equippedSecondary,
  equippedBoth,
  equippedTwoHands,
  equippedTempBonus,
  carriedNeither,
  contained,
  notCarried;

  bool isEquipped() {
    switch (this) {
      case EquipmentLocation.carriedNeither:
      case EquipmentLocation.contained:
      case EquipmentLocation.notCarried:
        return false;
      default:
        return true;
    }
  }

  String getString() {
    switch (this) {
      case EquipmentLocation.equippedNeither: return 'Neither';
      case EquipmentLocation.equippedPrimary: return 'Primary Hand';
      case EquipmentLocation.equippedSecondary: return 'Secondary Hand';
      case EquipmentLocation.equippedBoth: return 'Both Hands';
      case EquipmentLocation.equippedTwoHands: return 'Two Hands';
      case EquipmentLocation.equippedTempBonus: return 'Temp Bonus';
      case EquipmentLocation.carriedNeither: return 'Carried';
      case EquipmentLocation.contained: return 'Contained';
      case EquipmentLocation.notCarried: return 'Not Carried';
    }
  }
}
