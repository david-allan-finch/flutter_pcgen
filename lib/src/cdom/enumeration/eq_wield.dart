import '../../core/player_character.dart';
import '../../core/equipment.dart';

// Represents how a weapon is wielded.
enum EqWield {
  unarmed,
  light,
  oneHanded,
  twoHanded;

  bool checkWield(PlayerCharacter pc, Equipment equipment) {
    switch (this) {
      case EqWield.unarmed: return false;
      case EqWield.light: return equipment.isWeaponLightForPC(pc);
      case EqWield.oneHanded: return equipment.isWeaponOneHanded(pc);
      case EqWield.twoHanded: return equipment.isWeaponTwoHanded(pc);
    }
  }

  @override
  String toString() {
    switch (this) {
      case EqWield.oneHanded: return '1 Handed';
      case EqWield.twoHanded: return '2 Handed';
      default: return name;
    }
  }
}
