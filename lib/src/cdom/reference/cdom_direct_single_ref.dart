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
// Translation of pcgen.cdom.reference.CDOMDirectSingleRef
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'cdom_single_ref.dart';

// A direct reference that holds an object inline (no lookup needed).
class CDOMDirectSingleRef<T> implements CDOMSingleRef<T> {
  final T _obj;

  CDOMDirectSingleRef(this._obj);

  static CDOMDirectSingleRef<T> getRef<T>(T obj) => CDOMDirectSingleRef(obj);

  @override
  T get() => _obj;

  @override
  bool hasBeenResolved() => true;

  @override
  bool contains(T obj) => identical(_obj, obj) || _obj == obj;

  @override
  List<T> getContainedObjects() => [_obj];

  @override
  String getLSTformat([String? joinWith]) => _obj.toString();

  @override
  int getReferenceCount() => 1;

  @override
  String? getReferenceClass() => _obj.runtimeType.toString();

  @override
  String getPersistentFormat() => getLSTformat();

  @override
  String toString() => 'CDOMDirectSingleRef($_obj)';
}
