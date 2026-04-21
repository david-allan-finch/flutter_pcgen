//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Created: November 8, 2006
//
// Translation of pcgen.core.SpellProgressionCache
import 'dart:collection' show SplayTreeMap;

// Caches known/specialty-known/cast spell progression lists for a PCClass.
// Each Progression maps class level → list of Formula (one per spell level).
class SpellProgressionCache {
  _Progression? _knownProgression;
  _Progression? _specialtyKnownProgression;
  _Progression? _castProgression;

  void setKnown(int iLevel, List<dynamic> aList) {
    _knownProgression ??= _Progression();
    _knownProgression!.setProgression(iLevel, aList);
  }

  bool hasKnownProgression() =>
      _knownProgression != null && _knownProgression!.hasProgression();

  List<dynamic>? getKnownForLevel(int aLevel) =>
      _knownProgression?.getProgressionForLevel(aLevel);

  int getHighestKnownSpellLevel() =>
      _knownProgression?.getHighestSpellLevel() ?? 0;

  void setSpecialtyKnown(int aLevel, List<dynamic> aList) {
    _specialtyKnownProgression ??= _Progression();
    _specialtyKnownProgression!.setProgression(aLevel, aList);
  }

  bool hasSpecialtyKnownProgression() =>
      _specialtyKnownProgression != null &&
      _specialtyKnownProgression!.hasProgression();

  List<dynamic>? getSpecialtyKnownForLevel(int aLevel) =>
      _specialtyKnownProgression?.getProgressionForLevel(aLevel);

  List<dynamic>? setCast(int aLevel, List<dynamic> aList) {
    _castProgression ??= _Progression();
    return _castProgression!.setProgression(aLevel, aList);
  }

  bool hasCastProgression() =>
      _castProgression != null && _castProgression!.hasProgression();

  List<dynamic>? getCastForLevel(int aLevel) =>
      _castProgression?.getProgressionForLevel(aLevel);

  int getHighestCastSpellLevel() =>
      _castProgression?.getHighestSpellLevel() ?? 0;

  int getMinLevelForSpellLevel(int spellLevel, bool allowBonus) {
    if (_castProgression != null) {
      final lvl = _castProgression!.getMinLevelForSpellLevel(spellLevel, allowBonus);
      if (lvl != -1) return lvl;
    }
    if (_knownProgression != null) {
      return _knownProgression!.getMinLevelForSpellLevel(spellLevel, allowBonus);
    }
    return -1;
  }

  int getMaxSpellLevelForClassLevel(int classLevel) {
    if (_castProgression != null) {
      final list = _castProgression!.getProgressionForLevel(classLevel);
      if (list != null) return list.length - 1;
    }
    if (_knownProgression != null) {
      final list = _knownProgression!.getProgressionForLevel(classLevel);
      if (list != null) return list.length - 1;
    }
    return -1;
  }

  bool isEmpty() =>
      _knownProgression == null &&
      _castProgression == null &&
      _specialtyKnownProgression == null;

  SpellProgressionCache clone() {
    final spi = SpellProgressionCache();
    if (_knownProgression != null) spi._knownProgression = _knownProgression!.clone();
    if (_specialtyKnownProgression != null) {
      spi._specialtyKnownProgression = _specialtyKnownProgression!.clone();
    }
    if (_castProgression != null) spi._castProgression = _castProgression!.clone();
    return spi;
  }
}

class _Progression {
  // Sorted map: class level → list of Formula (one per spell level 0..n)
  final SplayTreeMap<int, List<dynamic>> _progressionMap = SplayTreeMap();

  List<dynamic>? setProgression(int iLevel, List<dynamic> aList) {
    if (iLevel < 1) {
      throw ArgumentError('Level must be >= 1 in spell progression');
    }
    if (aList.isEmpty) {
      throw ArgumentError('Cannot add empty spell progression list to level $iLevel');
    }
    return _progressionMap[iLevel] = List<dynamic>.from(aList);
  }

  bool hasProgression() => _progressionMap.isNotEmpty;

  List<dynamic>? getProgressionForLevel(int classLevel) {
    if (_progressionMap.isEmpty) return null;
    if (_progressionMap.containsKey(classLevel)) {
      return List<dynamic>.from(_progressionMap[classLevel]!);
    }
    // Fall back to highest level <= classLevel
    final keys = _progressionMap.keys.where((k) => k < classLevel).toList();
    if (keys.isEmpty) return null;
    final key = keys.last;
    return List<dynamic>.from(_progressionMap[key]!);
  }

  int getMinLevelForSpellLevel(int spellLevel, bool allowBonus) {
    for (final entry in _progressionMap.entries) {
      final list = entry.value;
      for (var lvl = spellLevel; lvl < list.length; lvl++) {
        if (allowBonus || int.parse(list[lvl].toString()) != 0) {
          return entry.key;
        }
      }
    }
    return -1;
  }

  int getHighestSpellLevel() {
    int highest = -1;
    for (final list in _progressionMap.values) {
      if (list.length - 1 > highest) highest = list.length - 1;
    }
    return highest;
  }

  _Progression clone() {
    final p = _Progression();
    p._progressionMap.addAll(_progressionMap);
    return p;
  }
}

