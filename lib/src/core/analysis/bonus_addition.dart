import '../../../cdom/base/cdom_object.dart';
import '../../globals.dart';
import '../../player_character.dart';

// Applies or removes saveable bonus strings from a PlayerCharacter.
final class BonusAddition {
  BonusAddition._();

  static void applyBonus(
      String bonusString, String chooseString, PlayerCharacter aPC, CDOMObject target) {
    bonusString = _makeBonusString(bonusString, chooseString, aPC);
    final aBonus = _newBonus(Globals.context, bonusString);
    if (aBonus != null) {
      aPC.addSaveableBonus(aBonus, target);
    }
  }

  static void removeBonus(String bonusString, PlayerCharacter aPC, CDOMObject target) {
    final aBonus = _newBonus(Globals.context, bonusString);
    final bonusStrRep = aBonus.toString();
    dynamic toRemove;

    for (final listBonus in aPC.getSaveableBonusList(target)) {
      if (listBonus.toString() == bonusStrRep) {
        toRemove = listBonus;
      }
    }

    if (toRemove != null) {
      aPC.removeSaveableBonus(toRemove, target);
    } else {
      print('removeBonus: Could not find bonus: $bonusString in bonusList '
          '${aPC.getSaveableBonusList(target)}');
    }
  }

  static String _makeBonusString(
      String bonusString, String chooseString, PlayerCharacter aPC) {
    int i = chooseString.lastIndexOf(' ');
    String classString = '';
    String levelString = '';

    if (bonusString.startsWith('BONUS:')) {
      bonusString = bonusString.substring(6);
    }

    bool lockIt = bonusString.endsWith('.LOCK');
    if (lockIt) {
      bonusString = bonusString.substring(0, bonusString.lastIndexOf('.LOCK'));
    }

    if (i >= 0) {
      classString = chooseString.substring(0, i);
      if (i < chooseString.length) {
        levelString = chooseString.substring(i + 1);
      }
    }

    while (bonusString.lastIndexOf('TYPE=%') >= 0) {
      i = bonusString.lastIndexOf('TYPE=%');
      bonusString = bonusString.substring(0, i + 5) + classString + bonusString.substring(i + 6);
    }

    while (bonusString.lastIndexOf('CLASS=%') >= 0) {
      i = bonusString.lastIndexOf('CLASS=%');
      bonusString = bonusString.substring(0, i + 6) + classString + bonusString.substring(i + 7);
    }

    while (bonusString.lastIndexOf('LEVEL=%') >= 0) {
      i = bonusString.lastIndexOf('LEVEL=%');
      bonusString = bonusString.substring(0, i + 6) + levelString + bonusString.substring(i + 7);
    }

    if (lockIt) {
      i = bonusString.lastIndexOf('|');
      final val = aPC.getVariableValue(bonusString.substring(i + 1), '');
      bonusString = '${bonusString.substring(0, i)}|$val';
    }

    return bonusString;
  }

  // Stub: Bonus.newBonus — returns dynamic BonusObj or null
  static dynamic _newBonus(dynamic context, String bonusString) => null;
}
