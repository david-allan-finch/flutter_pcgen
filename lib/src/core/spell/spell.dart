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
// Translation of pcgen.core.spell.Spell
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents a magic spell from the game rules.
///
/// Translated from pcgen.core.spell.Spell. Spells are Ungranted (cannot be
/// directly granted to PCs) and are identified by their key name.
final class Spell extends PObject {
  /// Generate LST format text for this spell.
  String getPCCText() {
    final txt = <String>[getDisplayName()];
    // Additional fields (school, range, duration, etc.) would be serialized here
    // in the full implementation using the LoadContext unparse infrastructure.
    return txt.join('\t');
  }

  @override
  bool operator ==(Object other) =>
      other is Spell &&
      getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  /// Hashcode based on key name (case-insensitive collisions are acceptable).
  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  String toString() => getDisplayName();
}
