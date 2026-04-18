import '../equipment.dart';
import '../p_object.dart';
import '../pc_stat.dart';
import '../player_character.dart';
import '../bonus/bonus_obj.dart';

// Utility class for computing bonus values from BONUS: tags.
abstract final class BonusCalc {
  static bool _dontRecurse = false;

  static int getStatMod(PObject po, PCStat stat, PlayerCharacter aPC) {
    return charBonusTo(po, 'STAT', stat.getKeyName(), aPC).toInt();
  }

  static double charBonusTo(PObject po, String aType, String aName, PlayerCharacter aPC) {
    return bonusTo(po, aType, aName, aPC, po.getBonusList(aPC), aPC);
  }

  static double equipBonusTo(Equipment po, String aType, String aName, PlayerCharacter aPC) {
    return bonusTo(po, aType, aName, po, po.getBonusListForEquip(po), aPC);
  }

  static double bonusTo(PObject po, String aType, String aName, Object obj,
      List<BonusObj> aBonusList, PlayerCharacter aPC) {
    if (aBonusList.isEmpty) return 0;

    double retVal = 0;
    aType = aType.toUpperCase();
    aName = aName.toUpperCase();
    final aTypePlusName = '$aType.$aName.';

    // Recursion guard for feats
    if (!_dontRecurse && po is Ability && obj is PlayerCharacter &&
        !obj.checkRule('FEATPRE')) {
      _dontRecurse = true;
      bool returnZero = !po.qualifies(aPC, po);
      _dontRecurse = false;
      if (returnZero) return 0;
    }

    int iTimes = 1;
    if ('VAR' == aType) {
      iTimes = aPC.getConsolidatedAssociationList(po).length;
      if (iTimes < 1) iTimes = 1;
    }

    for (final bonus in aBonusList) {
      String bString = bonus.toString().toUpperCase();

      final assocList = aPC.getConsolidatedAssociationList(po);
      if (assocList.isNotEmpty) {
        int idx = bString.indexOf('%VAR');
        int span = 4;
        if (idx == -1) {
          idx = bString.indexOf('%LIST|');
          span = 5;
        }
        if (idx >= 0) {
          final firstPart = bString.substring(0, idx);
          final secondPart = bString.substring(idx + span);
          for (final assoc in assocList) {
            final xString = (firstPart + assoc + secondPart).toUpperCase();
            retVal += _calcBonus(po, xString, aType, aName, aTypePlusName, obj, iTimes, bonus, aPC);
          }
        } else {
          retVal += _calcBonus(po, bString, aType, aName, aTypePlusName, obj, iTimes, bonus, aPC);
        }
      } else {
        retVal += _calcBonus(po, bString, aType, aName, aTypePlusName, obj, iTimes, bonus, aPC);
      }
    }

    return retVal;
  }

  static double _calcBonus(PObject po, String bString, String aType, String aName,
      String aTypePlusName, Object obj, int iTimes, BonusObj aBonusObj, PlayerCharacter aPC) {
    final parts = bString.split('|');
    if (parts.length < 3) return 0;

    final aString0 = parts[0];
    if (!aString0.toUpperCase().contains(aType) || aString0.endsWith('%LIST') || aName == 'ALL') return 0;

    final aList = parts[1];
    if (aList != 'LIST' && aList != 'ALL' && !aList.toUpperCase().contains(aName.toUpperCase())) return 0;

    if (aList == 'ALL' && (aName.contains('STAT=') || aName.contains('TYPE=') ||
        aName.contains('LIST') || aName.contains('VAR'))) return 0;

    final valueString = parts[2];

    double iBonus;
    if (obj is PlayerCharacter) {
      iBonus = obj.getVariableValue(valueString, '').toDouble();
    } else if (obj is Equipment) {
      iBonus = obj.getVariableValue(valueString, '', aPC).toDouble();
    } else {
      iBonus = double.tryParse(valueString) ?? 0.0;
    }

    final possibleBonusTypeString = aBonusObj.getTypeString();

    // Check prerequisites
    if (obj is PlayerCharacter) {
      if (!aBonusObj.qualifies(obj, po)) return 0;
    } else if (obj is Equipment) {
      if (!aBonusObj.passesAllPrereqs(obj, aPC)) return 0;
    }

    double bonus = 0;
    String? bonusTypeString;
    var tpn = aTypePlusName;

    if (aList.toUpperCase() == 'LIST') {
      // association-expanded — already handled above
    } else if (aList.toUpperCase() == 'ALL') {
      tpn = '$aType.$aName.';
      bonus = iBonus;
      bonusTypeString = possibleBonusTypeString;
    } else {
      for (final token in aList.split(',')) {
        if (token.toUpperCase() == aName) {
          bonus += iBonus;
          bonusTypeString = possibleBonusTypeString;
        }
      }
    }

    if (obj is Equipment) {
      obj.setBonusStackFor(bonus * iTimes, '$tpn$bonusTypeString');
    }

    if (aList == 'ALL') return 0;

    return bonus * iTimes;
  }
}
