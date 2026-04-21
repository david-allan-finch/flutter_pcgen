//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.BioSet

import 'package:flutter_pcgen/src/core/age_set.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

// ---------------------------------------------------------------------------
// BioSet — bio data (age/height/weight/hair/eyes/skin) for races by region
// ---------------------------------------------------------------------------

/// Holds bio randomization tables loaded from biosettings .lst files.
///
/// Data is keyed by region (optional String, null = "no region") and race name.
/// Within each (region, race) combination, tags like "BASEAGE", "HT", "WT",
/// "HAIR", "EYES", "SKINTONE" map to per-age-set lists of values.
final class BioSet extends PObject {
  // ageMap: region -> index -> AgeSet
  // null key = "Optional.empty()" / no region
  final Map<String?, Map<int, AgeSet>> _ageMap = {};

  // ageNames: case-insensitive name -> age-set index
  final Map<String, int> _ageNames = {};

  // userMap: region -> race -> tag -> [value per age set index]
  // The same TripleKeyMapToList pattern from Java
  final Map<String?, Map<String, Map<String, List<String>>>> _userMap = {};

  // ---------------------------------------------------------------------------
  // AgeSet access
  // ---------------------------------------------------------------------------

  /// Returns the AgeSet for [region] and [index].
  /// Falls back to the no-region AgeSet if none found for the given region.
  AgeSet? getAgeSet(String? region, int index) {
    AgeSet? ageSet = _ageMap[region]?[index];
    if (ageSet == null && region != null) {
      ageSet = _ageMap[null]?[index];
    }
    return ageSet;
  }

  /// Returns the numeric index for the named age category (case-insensitive).
  /// Returns -1 if the name is not found.
  int getAgeSetNamed(String ageCategory) {
    return _ageNames[ageCategory.toLowerCase()] ?? -1;
  }

  /// Adds [ageSet] to this BioSet for [region].
  void addToAgeMap(String? region, AgeSet ageSet) {
    _ageMap.putIfAbsent(region, () => <int, AgeSet>{})[ageSet.getIndex()] = ageSet;
  }

  /// Registers an age category name with its numeric index.
  void addToNameMap(String name, int index) {
    _ageNames[name.toLowerCase()] = index;
    _ageNames[name] = index; // also store original case
  }

  // ---------------------------------------------------------------------------
  // User map (race-specific bio tags by age set)
  // ---------------------------------------------------------------------------

  /// Adds a tag value for [race] in [region] at the given [ageSetIndex].
  ///
  /// [tag] must be in the format "KEY:value". Intermediate indices are padded
  /// with "0" to keep the list length consistent.
  void addToUserMap(String? region, String race, String tag, int ageSetIndex) {
    final colonIdx = tag.indexOf(':');
    if (colonIdx < 0) return; // invalid — no colon
    final key = tag.substring(0, colonIdx);
    final value = tag.substring(colonIdx + 1);

    final raceMap = _userMap
        .putIfAbsent(region, () => {})
        .putIfAbsent(race, () => {});
    final list = raceMap.putIfAbsent(key, () => []);

    // Pad list with "0" for any missing age-set indices
    while (list.length < ageSetIndex) {
      list.add('0');
    }
    list.add(value);
  }

  void clearUserMap() => _userMap.clear();

  /// Returns the list of values for [key] on [race] in [region] (or null region).
  List<String>? getValuesFor(String? region, String race, String key) {
    return _userMap[region]?[race]?[key] ??
        _userMap[null]?[race]?[key];
  }

  // ---------------------------------------------------------------------------
  // Randomization
  // ---------------------------------------------------------------------------

  /// Randomizes bio attributes for [pc] based on a dot-delimited [randomizeStr].
  ///
  /// Recognized tokens: AGECAT<n>, AGE, HT, WT, EYES, HAIR, SKIN.
  void randomize(String randomizeStr, dynamic pc) {
    final tokens = randomizeStr.split('.');
    final ranList = <String>[];

    for (final token in tokens) {
      if (token.startsWith('AGECAT')) {
        final index = int.tryParse(token.substring(6));
        if (index != null) _generateAge(index, false, pc);
      } else {
        ranList.add(token);
      }
    }

    if (ranList.contains('AGE')) _generateAge(0, true, pc);
    if (ranList.contains('HT') || ranList.contains('WT')) _generateHeightWeight(pc);
    if (ranList.contains('EYES')) {
      final eyes = _generateBioValue('EYES', pc);
      try { (pc as dynamic).setEyeColor(eyes); } catch (_) {}
    }
    if (ranList.contains('HAIR')) {
      final hair = _generateBioValue('HAIR', pc);
      try { (pc as dynamic).setHairColor(hair); } catch (_) {}
    }
    if (ranList.contains('SKIN')) {
      final skin = _generateBioValue('SKINTONE', pc);
      try { (pc as dynamic).setSkinColor(skin); } catch (_) {}
    }
  }

  void _generateAge(int index, bool useFirst, dynamic pc) {
    // TODO: resolve race region, pick age-set values, parse roll formula
  }

  void _generateHeightWeight(dynamic pc) {
    // TODO: resolve race HT/WT tables, roll dice, update pc
  }

  String _generateBioValue(String addKey, dynamic pc) {
    // TODO: look up value list for race/region, pick random entry
    return '';
  }

  // ---------------------------------------------------------------------------
  // PCC text export
  // ---------------------------------------------------------------------------

  String getBaseRegionPCCText(String race) {
    final sb = StringBuffer();
    // TODO: format the user map for the given race (no-region) into LST text
    return sb.toString();
  }

  @override
  String toString() {
    return 'AgeMap: $_ageMap\nUserMap: $_userMap';
  }
}
