//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.SkillModifier
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/core/analysis/skill_info_utilities.dart';
import 'package:flutter_pcgen/src/core/analysis/skill_rank_control.dart';

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
