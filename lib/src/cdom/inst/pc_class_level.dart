//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.inst.PCClassLevel
import '../base/cdom_object.dart';
import '../enumeration/string_key.dart';

// Represents items gained at a specific level of a PCClass.
final class PCClassLevel extends CDOMObject {
  @override
  int get hashCode {
    final name = getDisplayName();
    return name == null ? 0 : name.hashCode;
  }

  @override
  bool operator ==(Object obj) =>
      obj is PCClassLevel && obj.isCDOMEqual(this);

  @override
  bool isType(String type) => false;

  String? getQualifiedKey() => get(StringKey.qualifiedKey);

  @override
  String toString() => getDisplayName() ?? '';

  PCClassLevel clone() {
    final copy = PCClassLevel();
    cloneTo(copy);
    return copy;
  }
}
