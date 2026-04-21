//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.core.analysis.SpellLevel
import '../../cdom/base/cdom_list.dart';
import '../domain.dart';
import '../pc_class.dart';
import '../player_character.dart';
import '../spell.dart';

abstract final class SpellLevel {
  // Returns true if the spell is available at levelMatch from any of the given lists.
  // levelMatch == -1 means "any level".
  static bool levelForKeyContains(Spell sp, List<CDOMList<Spell>> lists, int levelMatch, PlayerCharacter aPC) {
    final pcli = aPC.getSpellLevelInfo(sp);
    final resultSet = <int>{};
    for (final spellList in lists) {
      final levels = pcli[spellList];
      if (levels != null) resultSet.addAll(levels);
    }
    return (levelMatch == -1 && resultSet.isNotEmpty) ||
        (levelMatch >= 0 && resultSet.contains(levelMatch));
  }

  static List<int> levelForKey(Spell sp, List<CDOMList<Spell>> lists, PlayerCharacter aPC) {
    return lists.map((list) => getFirstLvlForKey(sp, list, aPC)).toList();
  }

  // Returns the first (minimum) level for the spell in the given list, or -1.
  static int getFirstLvlForKey(Spell sp, CDOMList<Spell> list, PlayerCharacter aPC) {
    final wLevelInfo = aPC.getSpellLevelInfo(sp);
    if (wLevelInfo.isNotEmpty) {
      final levelList = wLevelInfo[list];
      if (levelList != null && levelList.isNotEmpty) {
        return levelList.reduce((a, b) => a < b ? a : b);
      }
    }
    return -1;
  }

  // Returns true if the spell is of the given level in any spell list for this PC.
  static bool isLevel(Spell sp, int aLevel, PlayerCharacter aPC) {
    final masterLists = aPC.gameMode.masterLists;
    for (final pcc in aPC.getClassSet()) {
      final csl = pcc.classSpellList;
      final assoc = masterLists.getAssociations(csl, sp);
      if (assoc != null) {
        for (final apo in assoc) {
          if (apo.passesAll(aPC, sp) && apo.getSpellLevel() == aLevel) {
            return true;
          }
        }
      }
    }
    for (final domain in aPC.getDomainSet()) {
      final dsl = domain.domainSpellList;
      final assoc = masterLists.getAssociations(dsl, sp);
      if (assoc != null) {
        for (final apo in assoc) {
          if (apo.passesAll(aPC, sp) && apo.getSpellLevel() == aLevel) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static int getFirstLevelForKey(Spell sp, List<CDOMList<Spell>> lists, PlayerCharacter aPC) {
    final levelInts = levelForKey(sp, lists, aPC);
    for (final level in levelInts) {
      if (level > -1) return level;
    }
    return -1;
  }
}
