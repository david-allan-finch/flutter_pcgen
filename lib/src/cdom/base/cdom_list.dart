//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.CDOMList
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/prereq_object.dart';

/// A CDOMList is an identifier used to identify CDOMObject relationships.
///
/// It is intended to be used in situations where groups of CDOMObjects require
/// some form of additional information beyond mere presence. One example would
/// be the Spell Level of a given Spell in a CDOMList of Spells.
abstract interface class CDOMList<T extends CDOMObject>
    implements PrereqObject {
  /// Returns the Type of Object this CDOMList will identify.
  Type getListClass();

  /// Returns the key name for this CDOMList.
  String getKeyName();

  /// Returns true if this CDOMList has the given Type.
  bool isType(String type);

  /// Returns a representation of this CDOMList, suitable for storing in an LST
  /// file.
  String getLSTformat([bool useAny = false]);
}
