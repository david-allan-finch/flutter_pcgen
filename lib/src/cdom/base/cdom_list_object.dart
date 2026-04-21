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
// Translation of pcgen.cdom.base.CDOMListObject
import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

/// This is an abstract object intended to be used as a basis for "concrete"
/// CDOMList objects.
///
/// CDOMListObject provides basic equality, ensuring matching Class, matching
/// underlying class (the Class of objects in the CDOMList) and matching List
/// name. It does not fully test the underlying CDOMObject contents.
abstract class CDOMListObject<T extends CDOMObject> extends ConcretePrereqObject
    implements CDOMList<T>, Loadable {
  String? _name;
  String? _keyName;
  String? _sourceURI;

  @override
  String getKeyName() => _keyName ?? _name ?? '';

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) {
    _sourceURI = source;
  }

  void setKeyName(String key) {
    _keyName = key;
  }

  @override
  String getDisplayName() => _name ?? '';

  @override
  String getLSTformat([bool useAny = false]) => getKeyName();

  @override
  bool isInternal() => false;

  @override
  void setName(String n) {
    _name = n;
  }

  @override
  String toString() => getKeyName();
}
