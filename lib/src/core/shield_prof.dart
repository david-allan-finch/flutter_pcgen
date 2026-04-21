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
// Translation of pcgen.core.ShieldProf
import 'package:flutter_pcgen/src/cdom/base/ungranted.dart';
import 'pcobject.dart';

// Represents a shield proficiency that a character may possess.
final class ShieldProf extends PCObject
    implements Comparable<Object>, Ungranted {
  @override
  int compareTo(Object o1) =>
      getKeyName().toLowerCase().compareTo((o1 as ShieldProf).getKeyName().toLowerCase());

  @override
  bool operator ==(Object obj) =>
      obj is ShieldProf &&
      getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;
}
