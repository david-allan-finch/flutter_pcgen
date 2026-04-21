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
// Translation of pcgen.cdom.base.AssociationSupport
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_object.dart';

// Delegate helper that implements AssociatedObject using a HashMap.
class AssociationSupport implements AssociatedObject {
  Map<AssociationKey<dynamic>, Object?>? _associationMap;

  @override
  void setAssociation<T>(AssociationKey<T> key, T value) {
    _associationMap ??= {};
    _associationMap![key] = value;
  }

  @override
  T? getAssociation<T>(AssociationKey<T> key) {
    if (_associationMap == null) return null;
    final v = _associationMap![key];
    return v == null ? null : key.cast(v);
  }

  @override
  List<AssociationKey<dynamic>> getAssociationKeys() {
    if (_associationMap == null) return [];
    return List.of(_associationMap!.keys);
  }

  @override
  bool hasAssociations() => _associationMap != null && _associationMap!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AssociationSupport) return false;
    final myEmpty = _associationMap == null || _associationMap!.isEmpty;
    final otherEmpty = other._associationMap == null || other._associationMap!.isEmpty;
    if (myEmpty && otherEmpty) return true;
    if (myEmpty != otherEmpty) return false;
    return _associationMap == other._associationMap;
  }

  @override
  int get hashCode => _associationMap?.length ?? 0;
}
