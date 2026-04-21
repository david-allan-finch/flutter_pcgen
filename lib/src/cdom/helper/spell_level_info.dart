//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.helper.SpellLevelInfo
import '../../core/pc_class.dart';
import '../../core/player_character.dart';
import 'spell_level.dart';

// Pairs a class filter with min/max spell-level formulas for the SPELLLEVEL token.
class SpellLevelInfo {
  final dynamic _filter; // PrimitiveCollection<PCClass>
  final dynamic _minimumLevel; // Formula
  final dynamic _maximumLevel; // Formula

  SpellLevelInfo(dynamic classFilter, dynamic minLevel, dynamic maxLevel)
      : _filter = classFilter,
        _minimumLevel = minLevel,
        _maximumLevel = maxLevel;

  @override
  String toString() =>
      '${_filter.getLSTformat(false)}|$_minimumLevel|$_maximumLevel';

  List<SpellLevel> getLevels(PlayerCharacter pc) {
    final list = <SpellLevel>[];
    // filter.getCollection stub
    for (final cl in (_filter.getCollection(pc, null) as List<PCClass>? ?? const [])) {
      final min = _minimumLevel.resolve(pc, cl.getQualifiedKey()).toInt() as int;
      final max = _maximumLevel.resolve(pc, cl.getQualifiedKey()).toInt() as int;
      for (int i = min; i <= max; i++) {
        list.add(SpellLevel(cl, i));
      }
    }
    return list;
  }

  bool allow(PlayerCharacter pc, PCClass cl) =>
      pc.getClassKeyed(cl.getKeyName()) != null;
}
