//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.Race

import 'package:flutter_pcgen/src/cdom/enumeration/formula_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents a character race.
final class Race extends PObject {
  /// Returns true if the race has unlimited hit-dice advancement.
  bool isAdvancementUnlimited() {
    final hda = getListFor<int>(ListKey.getConstant<int>('HITDICE_ADVANCEMENT'));
    return hda == null || hda.last == 0x7fffffff; // Integer.MAX_VALUE
  }

  /// Returns the maximum hit dice this race can advance to.
  int maxHitDiceAdvancement() {
    final hda = getListFor<int>(ListKey.getConstant<int>('HITDICE_ADVANCEMENT'));
    if (hda == null || hda.isEmpty) return 0;
    return hda.reduce((a, b) => a > b ? a : b);
  }

  /// Returns the CHOOSE info for this race (used by CHOOSE: processing).
  dynamic getChooseInfo() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('CHOOSE_INFO'));

  /// Returns the SELECT formula used by CHOOSE processing.
  dynamic getSelectFormula() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('SELECT'));

  /// Returns the CHOOSE actors list.
  List<dynamic> getActors() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('NEW_CHOOSE_ACTOR'));

  /// Returns the formula source string used by the formula engine.
  String getFormulaSource() => getKeyName();

  /// Returns the NUM_CHOICES formula.
  dynamic getNumChoices() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('NUM_CHOICES'));

  /// Returns the number of monster class levels (MONCLASSLEVELS).
  int getMonsterClassLevels() =>
      getInt(IntegerKey.getConstant('MONSTER_CLASS_LEVELS')) ?? 0;

  /// Returns the monster class for this race (MONCLASS token).
  dynamic getMonsterClass() =>
      getSafeObject(ObjectKey.getConstant<dynamic>('MONSTER_CLASS'));

  // ---- Race traits exposed to character facade ----------------------------

  /// Size abbreviation: F D T S M L H G C P (Medium = 'M').
  String getSize() => getSafeString(StringKey.sizeformula);

  /// Movement speeds as {type: feet} map, e.g. {'Walk': 30, 'Swim': 20}.
  Map<String, int> getMoveSpeeds() {
    try {
      final obj = getSafeObject(ObjectKey.getConstant<Map>('MOVE_SPEEDS'));
      if (obj is Map) return Map<String, int>.from(obj);
    } catch (_) {}
    // Fall back to parsing the raw MOVE string
    final raw = getSafeString(StringKey.tempvalue);
    if (raw.isEmpty) return {};
    final parts = raw.split(',');
    final result = <String, int>{};
    for (int i = 0; i + 1 < parts.length; i += 2) {
      final type  = parts[i].trim();
      final speed = int.tryParse(parts[i + 1].trim()) ?? 0;
      if (type.isNotEmpty) result[type] = speed;
    }
    return result;
  }

  /// Languages automatically known by this race (AUTO:LANG token).
  List<String> getAutoLanguages() {
    try {
      final list = getSafeListFor(ListKey.getConstant<String>('AUTO_LANG')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Vision types (e.g. 'Darkvision (60\')', 'Low-Light Vision').
  List<String> getVisionTypes() {
    try {
      final list = getSafeListFor(ListKey.getConstant<String>('VISION_TYPES')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) { return const []; }
  }

  /// Natural attacks from NATURALATTACKS token (list of 'Name:Count:Damage').
  List<String> getNaturalAttacks() {
    try {
      final list = getSafeListFor(ListKey.getConstant<String>('NATURAL_ATTACKS')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) { return const []; }
  }

  /// Bonus language choices offered to characters of this race (LANGBONUS token).
  List<String> getBonusLanguageChoices() {
    try {
      final list = getSafeListFor(ListKey.getConstant<String>('LANG_BONUS')) as List?;
      return list?.cast<String>() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Starting feats granted by the race (STARTFEATS token).
  int getStartFeats() =>
      getSafeObject(ObjectKey.getConstant<int>('START_FEATS')) as int? ?? 0;

  @override
  int get hashCode => getKeyName().hashCode;

  @override
  bool operator ==(Object other) =>
      other is Race && getKeyName() == other.getKeyName();
}
