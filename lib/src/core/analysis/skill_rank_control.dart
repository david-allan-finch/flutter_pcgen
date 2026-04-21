//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.analysis.SkillRankControl
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/pclevelinfo/pc_level_info.dart';
import 'package:flutter_pcgen/src/core/rule_constants.dart';
import 'package:flutter_pcgen/src/core/skill.dart';

abstract final class SkillRankControl {
  // Returns total ranks of a skill: rank + bonus ranks (racial, class, etc).
  static double getTotalRank(PlayerCharacter pc, Skill sk) {
    final rank = pc.getRank(sk) ?? 0.0;
    final baseRanks = rank;
    double ranks = baseRanks + getSkillRankBonusTo(pc, sk);
    if (!pc.checkRule(RuleConstants.skillMax) && pc.hasClass()) {
      final firstClass = pc.getClassList().first;
      double maxRanks = pc.getMaxRank(sk, firstClass).toDouble();
      maxRanks = maxRanks > baseRanks ? maxRanks : baseRanks;
      ranks = ranks < maxRanks ? ranks : maxRanks;
    }
    return ranks;
  }

  static void setZeroRanks(PCClass? aClass, PlayerCharacter aPC, Skill sk) {
    if (aClass == null) return;
    final rank = aPC.getSkillRankForClass(sk, aClass);
    if (rank != null) {
      aPC.removeSkillRankValue(sk, aClass);
      modRanks(-rank, aClass, false, aPC, sk);
    }
  }

  // Modify the rank. Returns an error message or empty string on success.
  static String modRanks(double rankMod, PCClass? aClass, bool ignorePrereqs, PlayerCharacter aPC, Skill sk) {
    int i = 0;
    if (!ignorePrereqs) {
      if (aClass == null) return 'You must be at least level one before you can purchase skills.';
      if (rankMod > 0.0 && !sk.qualifies(aPC, sk)) {
        return 'You do not meet the prerequisites required to take this skill.';
      }
      final sc = aPC.getSkillCostForClass(sk, aClass);
      i = sc.getCost();
      if (i == 0) return 'You cannot purchase this exclusive skill.';
      if (rankMod > 0.0 && aClass.getSkillPool(aPC) < (rankMod * i)) {
        return 'You do not have enough skill points.';
      }
      final maxRank = aPC.getMaxRank(sk, aClass).toDouble();
      if (!aPC.checkRule(RuleConstants.skillMax) && rankMod > 0.0) {
        final ttlRank = getTotalRank(aPC, sk);
        if (ttlRank >= maxRank) return 'Skill rank at maximum ($maxRank) for your level.';
        if (ttlRank + rankMod > maxRank) return 'Raising skill would make it above maximum ($maxRank) for your level.';
      }
    }
    if ((aPC.getRank(sk) ?? 0.0) + rankMod < 0.0) return 'Cannot lower rank below 0';

    final String classKey = aClass?.getKeyName() ?? 'None';
    final double currentRank = aPC.getSkillRankForClass(sk, aClass) ?? 0.0;

    if (currentRank == 0.0 && rankMod < 0.0) {
      return 'No more ranks found for class: $classKey. Try a different one.';
    }

    _modRanks2(rankMod, currentRank, aClass, aPC, sk);

    if (!ignorePrereqs && aClass != null) {
      aPC.setSkillPool(aClass, aClass.getSkillPool(aPC) - (i * rankMod).toInt());
    }

    return '';
  }

  static void replaceClassRank(PlayerCharacter pc, Skill sk, PCClass oldClass, PCClass newClass) {
    final rank = pc.getSkillRankForLocalClass(sk, oldClass);
    if (rank != null) {
      pc.removeSkillRankForLocalClass(sk, oldClass);
      pc.setSkillRankValue(sk, newClass, rank);
    }
  }

  static double _modRanks2(double rankChange, double curRank, PCClass? pcc, PlayerCharacter aPC, Skill sk) {
    final newRank = curRank + rankChange;
    if (newRank == 0.0) {
      aPC.removeSkillRankValue(sk, pcc);
    } else {
      aPC.setSkillRankValue(sk, pcc, newRank);
    }
    if (!aPC.isImporting) {
      // chooser handling omitted — deferred
    }
    aPC.calcActiveBonuses();
    return rankChange;
  }

  static double getSkillRankBonusTo(PlayerCharacter aPC, Skill sk) {
    double bonus = aPC.getTotalBonusTo('SKILLRANK', sk.getKeyName());
    for (final singleType in sk.getTrueTypeList(false)) {
      bonus += aPC.getTotalBonusTo('SKILLRANK', 'TYPE.$singleType');
    }
    _updateAdds(aPC, sk, bonus);
    return bonus;
  }

  static void _updateAdds(PlayerCharacter aPC, Skill sk, double bonus) {
    final adds = sk.getAdds();
    if (adds != null) {
      int iCount = 0;
      for (final ptc in adds) {
        iCount += aPC.getAssocCount(ptc);
      }
      final rank = aPC.getRank(sk) ?? 0.0;
      if (rank + bonus == 0.0) {
        if (iCount != 0) {
          aPC.removeAdds(sk);
          aPC.restoreRemovals(sk);
        }
      } else {
        if (iCount == 0) {
          aPC.applyAdds(sk);
          aPC.checkRemovals(sk);
        }
      }
    }
  }

  static void removeSkillsForTopLevel(PlayerCharacter pc, PCClass classBeingLevelledDown,
      int currentLevel, int pointsToRemove) {
    double remaining = pointsToRemove.toDouble();
    if (remaining <= 0.0) return;

    for (final skill in pc.getSkillSet()) {
      if (!skill.isVisibleForDisplay) continue;
      final aClass = pc.getClassList().isEmpty ? null : pc.getClassList().first;
      final maxRanks = pc.getMaxRank(skill, aClass).toDouble();
      final rankMod = maxRanks - getTotalRank(pc, skill);
      if (rankMod < 0) {
        final err = modRanks(rankMod, classBeingLevelledDown, true, pc, skill);
        if (err.isEmpty) {
          remaining += rankMod;
          if (remaining <= 0) break;
        }
      }
    }

    if (remaining != 0.0) {
      PCLevelInfo? targetLevel;
      int level = currentLevel - 1;
      while (level > 0) {
        final pcLI = pc.getLevelInfo(level - 1);
        if (pcLI.getClassKeyName() == classBeingLevelledDown.getKeyName()) {
          targetLevel = pcLI;
          break;
        }
        level--;
      }
      if (targetLevel == null && currentLevel > 0) {
        targetLevel = pc.getLevelInfo(currentLevel - 2);
      }
      if (targetLevel != null) {
        targetLevel.setSkillPointsRemaining(
            targetLevel.getSkillPointsRemaining() - remaining.toInt());
      }
    }
  }
}
