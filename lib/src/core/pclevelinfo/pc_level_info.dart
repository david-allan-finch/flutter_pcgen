//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.pclevelinfo.PCLevelInfo
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'pc_level_info_stat.dart';

// Represents the data kept about a level that a PC has added.
final class PCLevelInfo {
  List<PCLevelInfoStat>? statsPostModified;
  List<PCLevelInfoStat>? statsPreModified;
  String classKeyName;
  int classLevel = 0;
  int _skillPointsGained = -0x80000000; // Integer.MIN_VALUE sentinel
  int skillPointsRemaining = 0;

  PCLevelInfo(this.classKeyName);

  void setClassKeyName(String argClassKeyName) {
    classKeyName = argClassKeyName;
  }

  String getClassKeyName() => classKeyName;

  void setClassLevel(int arg) { classLevel = arg; }
  int getClassLevel() => classLevel;

  List<PCLevelInfoStat>? getModifiedStats(bool preMod) =>
      preMod ? statsPreModified : statsPostModified;

  void setSkillPointsGained(PlayerCharacter aPC, int arg) {
    setFixedSkillPointsGained(arg + _getBonusSkillPool(aPC));
  }

  int getSkillPointsGained(PlayerCharacter pc) {
    if (_skillPointsGained == -0x80000000 && classKeyName.isNotEmpty) {
      final aClass = pc.getClassKeyed(classKeyName);
      if (aClass != null) {
        _skillPointsGained = pc.recalcSkillPointMod(aClass, classLevel) + _getBonusSkillPool(pc);
      } else {
        _skillPointsGained = 0;
      }
    }
    return _skillPointsGained;
  }

  void setSkillPointsRemaining(int points) { skillPointsRemaining = points; }
  int getSkillPointsRemaining() => skillPointsRemaining;

  void setFixedSkillPointsGained(int arg) { _skillPointsGained = arg; }

  int getTotalStatMod(PCStat aStat, bool includePost) {
    int mod = 0;
    for (final stat in statsPreModified ?? []) {
      if (stat.stat == aStat) mod += stat.mod;
    }
    if (includePost) {
      for (final stat in statsPostModified ?? []) {
        if (stat.stat == aStat) mod += stat.mod;
      }
    }
    return mod;
  }

  void addModifiedStat(PCStat stat, int mod, bool isPreMod) {
    final List<PCLevelInfoStat> statList;
    if (isPreMod) {
      statsPreModified ??= [];
      statList = statsPreModified!;
    } else {
      statsPostModified ??= [];
      statList = statsPostModified!;
    }

    for (int i = 0; i < statList.length; i++) {
      final aStat = statList[i];
      if (stat == aStat.stat) {
        aStat.modifyStat(mod);
        if (aStat.mod == 0) statList.removeAt(i);
        return;
      }
    }
    statList.add(PCLevelInfoStat(stat, mod));
  }

  int _getBonusSkillPool(PlayerCharacter aPC) {
    int returnValue = 0;
    final aClass = aPC.getClassKeyed(classKeyName);
    // Point buy method bonus — depends on game settings; stub for now
    if (aClass != null) {
      returnValue += aClass.getBonusTo('SKILLPOOL', 'NUMBER', classLevel, aPC).toInt();
      returnValue -= aClass.getBonusTo('SKILLPOOL', 'NUMBER', classLevel - 1, aPC).toInt();
    }
    if (classLevel == 1) {
      returnValue += aPC.getTotalBonusTo('SKILLPOOL', 'CLASS.$classKeyName').toInt();
    }
    returnValue += aPC.getTotalBonusTo('SKILLPOOL', 'CLASS.$classKeyName;LEVEL.$classLevel').toInt();
    returnValue += aPC.getTotalBonusTo('SKILLPOOL', 'LEVEL.${aPC.getCharacterLevel(this)}').toInt();
    return returnValue;
  }

  PCLevelInfo clone() {
    final c = PCLevelInfo(classKeyName);
    if (statsPostModified != null) {
      c.statsPostModified = List.of(statsPostModified!);
    }
    if (statsPreModified != null) {
      c.statsPreModified = List.of(statsPreModified!);
    }
    c.classLevel = classLevel;
    c._skillPointsGained = _skillPointsGained;
    c.skillPointsRemaining = skillPointsRemaining;
    return c;
  }

  @override
  int get hashCode => classLevel * 17 + classKeyName.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is PCLevelInfo) {
      return classLevel == other.classLevel &&
          _skillPointsGained == other._skillPointsGained &&
          skillPointsRemaining == other.skillPointsRemaining &&
          classKeyName == other.classKeyName &&
          _listEquals(statsPreModified, other.statsPreModified) &&
          _listEquals(statsPostModified, other.statsPostModified);
    }
    return false;
  }

  bool _listEquals(List? a, List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
