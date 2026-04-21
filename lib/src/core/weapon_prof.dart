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
// Translation of pcgen.core.WeaponProf
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents weapon proficiency (e.g., Simple, Martial, Exotic weapons).
///
/// Translated from pcgen.core.WeaponProf. Equality and comparison are based
/// on the key name, case-insensitively.
final class WeaponProf extends PObject implements Comparable<Object> {
  /// Compares keyName only, case-insensitively.
  @override
  int compareTo(Object o1) {
    if (o1 is WeaponProf) {
      return getKeyName().toLowerCase().compareTo(o1.getKeyName().toLowerCase());
    }
    return getKeyName().toLowerCase().compareTo(o1.toString().toLowerCase());
  }

  /// Equality based on keyName only, case-insensitively.
  @override
  bool operator ==(Object obj) {
    return obj is WeaponProf &&
        getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();
  }

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  String toString() => getDisplayName();
}
