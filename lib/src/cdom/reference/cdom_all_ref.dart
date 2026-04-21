//
// Copyright (c) 2007-18 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.reference.CDOMAllRef
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';

// A reference to ALL objects of a given type.
class CDOMAllRef<T> extends CDOMReference<T> implements CDOMGroupRef<T> {
  final List<T> _objects = [];
  final String _typeName;

  CDOMAllRef(this._typeName) : super('ALL');

  @override
  void addResolution(T obj) {
    if (!_objects.contains(obj)) _objects.add(obj);
  }

  @override
  bool contains(T obj) => _objects.contains(obj);

  @override
  List<T> getContainedObjects() => List.unmodifiable(_objects);

  @override
  int getObjectCount() => _objects.length;

  @override
  String getReferenceDescription() => 'ALL objects of $_typeName';

  @override
  String? getChoice() => null;

  @override
  GroupingState getGroupingState() => GroupingState.any;

  @override
  @override
  String getLSTformat([bool useAny = false]) => useAny ? 'ANY' : 'ALL';

  @override
  Type getReferenceClass() => T;

  @override
  String getPersistentFormat() => 'ALL';

  @override
  String toString() => 'CDOMAllRef<$_typeName>';
}
