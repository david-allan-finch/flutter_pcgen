import '../../../cdom/base/cdom_object.dart';
import '../../player_character.dart';

// Activates or deactivates bonuses on a PlayerCharacter for a given CDOMObject.
final class BonusActivation {
  BonusActivation._();

  static void deactivateBonuses(CDOMObject po, dynamic aPC) {
    for (final bonus in po.getRawBonusList(aPC)) {
      aPC.setApplied(bonus, false);
    }
  }

  static void activateBonuses(CDOMObject po, dynamic aPC) {
    for (final aBonus in po.getRawBonusList(aPC)) {
      aPC.setApplied(aBonus, aBonus.qualifies(aPC, po));
    }
  }
}
