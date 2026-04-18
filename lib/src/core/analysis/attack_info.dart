import '../player_character.dart';
import '../display/character_display.dart';

enum AttackType { melee, ranged, grapple, unarmed }

abstract final class AttackInfo {
  static String getAttackInfo(PlayerCharacter pc, AttackType attackType, String modifier) {
    if (modifier == 'TOTAL') {
      if (attackType == AttackType.ranged) {
        final total = getTotalToken(pc, attackType);
        return pc.getAttackString(AttackType.ranged, total);
      } else if (attackType == AttackType.unarmed) {
        final total = getTotalToken(pc, AttackType.melee);
        return pc.getAttackString(AttackType.melee, total);
      } else {
        final total = getTotalToken(pc, attackType);
        return pc.getAttackString(AttackType.melee, total);
      }
    }
    return getSubToken(pc, attackType, modifier);
  }

  static int getTotalToken(PlayerCharacter pc, AttackType at) {
    final tohitBonus = pc.getTotalBonusTo('TOHIT', 'TOHIT').toInt() +
        pc.getTotalBonusTo('TOHIT', 'TYPE.${at.name.toUpperCase()}').toInt();
    final totalBonus = pc.getTotalBonusTo('COMBAT', 'TOHIT').toInt() +
        pc.getTotalBonusTo('COMBAT', 'TOHIT.${at.name.toUpperCase()}').toInt();
    return tohitBonus + totalBonus;
  }

  static String getSubToken(PlayerCharacter pc, AttackType attackType, String modifier) {
    switch (modifier) {
      case 'BASE':
        return _delta(getBaseToken(pc));
      case 'EPIC':
        return _delta(getEpicToken(pc));
      case 'MISC':
        return _delta(getMiscToken(pc, attackType));
      case 'SIZE':
        return _delta(getSizeToken(pc, attackType));
      case 'STAT':
        return _delta(getStatToken(pc.getDisplay(), attackType));
      default:
        return pc.getAttackStringByType(attackType);
    }
  }

  static int getBaseToken(PlayerCharacter pc) => pc.baseAttackBonus();

  static int getEpicToken(PlayerCharacter pc) =>
      pc.getBonusDueToType('COMBAT', 'TOHIT', 'EPIC').toInt();

  static int getMiscToken(PlayerCharacter pc, AttackType at) {
    final atName = at.name.toUpperCase();
    final tohitBonus = (pc.getTotalBonusTo('TOHIT', 'TOHIT').toInt() +
            pc.getTotalBonusTo('TOHIT', 'TYPE.$atName').toInt()) -
        pc.getDisplay().getStatBonusTo('TOHIT', 'TYPE.$atName').toInt() -
        pc.getSizeAdjustmentBonusTo('TOHIT', 'TOHIT').toInt();
    final miscBonus = (pc.getTotalBonusTo('COMBAT', 'TOHIT').toInt() +
            pc.getTotalBonusTo('COMBAT', 'TOHIT.$atName').toInt()) -
        pc.getDisplay().getStatBonusTo('COMBAT', 'TOHIT.$atName').toInt() -
        pc.getSizeAdjustmentBonusTo('COMBAT', 'TOHIT').toInt() -
        pc.getSizeAdjustmentBonusTo('COMBAT', 'TOHIT.$atName').toInt() -
        pc.getBonusDueToType('COMBAT', 'TOHIT', 'EPIC').toInt();
    return miscBonus + tohitBonus;
  }

  static int getSizeToken(PlayerCharacter pc, AttackType aType) {
    final atName = aType.name.toUpperCase();
    final tohitBonus = pc.getSizeAdjustmentBonusTo('TOHIT', 'TOHIT').toInt() +
        pc.getSizeAdjustmentBonusTo('TOHIT', 'TYPE.$atName').toInt();
    final sizeBonus = pc.getSizeAdjustmentBonusTo('COMBAT', 'TOHIT').toInt() +
        pc.getSizeAdjustmentBonusTo('COMBAT', 'TOHIT.$atName').toInt();
    return sizeBonus + tohitBonus;
  }

  static int getStatToken(CharacterDisplay display, AttackType at) {
    final atName = at.name.toUpperCase();
    final tohitBonus = display.getStatBonusTo('TOHIT', 'TYPE.$atName').toInt();
    final statBonus = display.getStatBonusTo('COMBAT', 'TOHIT.$atName').toInt();
    return statBonus + tohitBonus;
  }

  static String _delta(int val) => val >= 0 ? '+$val' : '$val';
}
