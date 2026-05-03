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
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.Skill

import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents a skill (e.g., Acrobatics, Perception).
final class Skill extends PObject {
  String getLocalScopeName() => 'PC.SKILL';

  /// Returns the abbreviation of the key ability stat for this skill.
  /// Stored during LST loading as a KeyStatRef via CDOMObjectKey('KEY_STAT').
  String getKeyStatAbb() {
    try {
      final keyStat = getSafeObject(CDOMObjectKey.getConstant<dynamic>('KEY_STAT'));
      if (keyStat is KeyStatRef) return keyStat.abbrev;
      return (keyStat as dynamic)?.get()?.getKeyName() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Returns true if this skill can be used untrained.
  bool isUntrained() =>
      getSafeObject(CDOMObjectKey.getConstant<bool>('USE_UNTRAINED', defaultValue: true))
          as bool? ??
      true;

  /// Returns true if this skill is exclusive to certain classes.
  bool isExclusive() =>
      getSafeObject(CDOMObjectKey.getConstant<bool>('EXCLUSIVE', defaultValue: false))
          as bool? ??
      false;

  /// Returns true if armor check penalty applies to this skill (ACHECK:YES).
  bool hasArmorCheckPenalty() =>
      getSafeObject(CDOMObjectKey.getConstant<bool>('ACHECK')) as bool? ?? false;

  /// Returns raw bonus objects for this skill for the given character.
  List<dynamic> getRawBonusList(dynamic pc) =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('BONUS'));

  @override
  bool operator ==(Object other) =>
      other is Skill &&
      getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;
}

// Thin wrapper so GenericLoader can store a stat abbreviation string
// in a way that Skill.getKeyStatAbb() can retrieve it.
class KeyStatRef {
  final String abbrev;
  const KeyStatRef(this.abbrev);
  // Mimics CDOMReference.getKeyName() for compatibility.
  String getKeyName() => abbrev;
}
