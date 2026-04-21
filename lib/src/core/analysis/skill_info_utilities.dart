//
// Copyright 2009 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.core.analysis.SkillInfoUtilities
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/skill.dart';

abstract final class SkillInfoUtilities {
  // Get the key stat abbreviation for a skill.
  static String getKeyStatFromStats(PlayerCharacter pc, Skill sk) {
    final stat = sk.keyStat;
    if (stat == null) {
      if (Globals.gameModeHasPointPool) {
        final statList = getKeyStatList(pc, sk, null);
        return statList.map((s) => s.getKeyName()).join();
      }
      return '';
    }
    return stat.get().getKeyName();
  }

  // Get a list of PCStat's that apply a SKILL bonus to this skill.
  static List<PCStat> getKeyStatList(PlayerCharacter pc, Skill sk, List<CDOMType>? typeList) {
    final aList = <PCStat>[];
    if (Globals.gameModeHasPointPool) {
      for (final aType in sk.getTrueTypeList(false)) {
        for (final stat in pc.getDisplay().getStatSet()) {
          final bonusList = stat.getBonusesForSkillType(aType);
          if (bonusList.isNotEmpty) {
            for (int i = 0; i < bonusList.length; i++) {
              aList.add(stat);
            }
            if (typeList != null && !typeList.contains(aType)) {
              typeList.add(aType);
            }
          }
        }
      }
    }
    return aList;
  }

  // Get an iterable of sub-types for a skill, excluding key stat and NONE.
  static Iterable<CDOMType> getSubtypeIterable(Skill sk) {
    final ret = List<CDOMType>.of(sk.getSafeListFor('TYPE'));
    final keystat = sk.keyStat;
    if (keystat == null) {
      ret.remove(CDOMType.none);
    } else {
      ret.remove(CDOMType.getConstant(keystat.get().getDisplayName()));
    }
    return ret;
  }
}
