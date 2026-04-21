//
// Copyright 2005 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.kit.KitStat
import '../../cdom/base/cdom_single_ref.dart';
import '../kit.dart';
import '../pc_stat.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitStat extends BaseKit {
  final Map<CDOMSingleRef<PCStat>, String> _statMap = {}; // stat ref → formula string

  void addStat(CDOMSingleRef<PCStat> stat, String statValueFormula) {
    if (_statMap.containsKey(stat)) {
      throw ArgumentError('Cannot redefine stat: $stat');
    }
    _statMap[stat] = statValueFormula;
  }

  bool isEmpty() => _statMap.isEmpty;

  @override
  bool testApply(Kit? aKit, PlayerCharacter aPC, List<String>? warnings) {
    for (final entry in _statMap.entries) {
      final mapStat = entry.key.get();
      final sVal = aPC.getVariableValue(entry.value, '').toInt();
      for (final currentStat in aPC.getStatSet()) {
        if (!aPC.isNonAbility(currentStat) && currentStat == mapStat) {
          aPC.setStat(currentStat, sVal);
          if (currentStat.getKeyName() == 'INT') {
            _recalculateSkillPoints(aPC);
          }
          break;
        }
      }
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) => testApply(null, aPC, null);

  @override
  String getObjectName() => 'Stats';

  @override
  String toString() {
    final parts = <String>[];
    for (final entry in _statMap.entries) {
      parts.add('${entry.key.getLSTformat(false)}=${entry.value}');
    }
    parts.sort();
    return parts.join('|');
  }

  void _recalculateSkillPoints(PlayerCharacter aPC) {
    final classes = aPC.getClassSet();
    aPC.calcActiveBonuses();
    if (classes.isNotEmpty) {
      for (final pcClass in classes) {
        aPC.setSkillPool(pcClass, 0);
        for (int j = 0; j < aPC.getLevelInfoSize(); j++) {
          final pcl = aPC.getLevelInfo(j);
          if (pcl.getClassKeyName() == pcClass.getKeyName()) {
            final spMod = aPC.recalcSkillPointMod(pcClass, j + 1);
            final alreadySpent = pcl.getSkillPointsGained(aPC) - pcl.getSkillPointsRemaining();
            pcl.setSkillPointsGained(aPC, spMod);
            pcl.setSkillPointsRemaining(pcl.getSkillPointsGained(aPC) - alreadySpent);
            final currentPool = aPC.getSkillPool(pcClass) ?? 0;
            aPC.setSkillPool(pcClass, currentPool + spMod);
          }
        }
      }
    }
  }
}
