import '../globals.dart';
import '../player_character.dart';
import '../skill.dart';
import 'skill_info_utilities.dart';
import 'skill_rank_control.dart';

abstract final class SkillModifier {
  static int modifier(Skill sk, PlayerCharacter aPC) {
    int bonus = 0;
    final keyName = sk.getKeyName();
    final statref = sk.keyStat;
    if (statref != null) {
      final stat = statref.get();
      bonus = aPC.getStatModFor(stat);
      bonus += aPC.getTotalBonusTo('SKILL', 'STAT.${stat.getKeyName()}').toInt();
    }
    bonus += aPC.getTotalBonusTo('SKILL', keyName).toInt();

    for (final singleType in sk.getTrueTypeList(false)) {
      bonus += aPC.getTotalBonusTo('SKILL', 'TYPE.$singleType').toInt();
    }

    bonus += aPC.getTotalBonusTo('SKILL', 'LIST').toInt();
    bonus += aPC.getTotalBonusTo('SKILL', 'ALL').toInt();

    if (aPC.isClassSkill(sk)) {
      bonus += aPC.getTotalBonusTo('CSKILL', keyName).toInt();
      for (final singleType in sk.getTrueTypeList(false)) {
        bonus += aPC.getTotalBonusTo('CSKILL', 'TYPE.$singleType').toInt();
      }
      bonus += aPC.getTotalBonusTo('CSKILL', 'LIST').toInt();
    }

    if (!aPC.isClassSkill(sk) && !sk.isExclusive) {
      bonus += aPC.getTotalBonusTo('CCSKILL', keyName).toInt();
      for (final singleType in sk.getTrueTypeList(false)) {
        bonus += aPC.getTotalBonusTo('CCSKILL', 'TYPE.$singleType').toInt();
      }
      bonus += aPC.getTotalBonusTo('CCSKILL', 'LIST').toInt();
    }

    bonus += sk.armorCheckBonus(aPC);

    final rankFormula = aPC.gameMode.rankModFormula;
    if (rankFormula.isNotEmpty) {
      final rankStr = rankFormula.replaceAll(r'$$RANK$$',
          SkillRankControl.getTotalRank(aPC, sk).toString());
      bonus += aPC.getVariableValue(rankStr, '').toInt();
    }

    return bonus;
  }

  static int getStatMod(Skill sk, PlayerCharacter pc) {
    final stat = sk.keyStat;
    if (stat == null) {
      int statMod = 0;
      if (Globals.gameModeHasPointPool) {
        final typeList = <dynamic>[];
        SkillInfoUtilities.getKeyStatList(pc, sk, typeList.cast());
        for (final type in typeList) {
          statMod += pc.getTotalBonusTo('SKILL', 'TYPE.$type').toInt();
        }
      }
      return statMod;
    } else {
      return pc.getStatModFor(stat.get());
    }
  }
}
