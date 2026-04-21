//
// Copyright 2005 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.AssociationListKey
import 'package:flutter_pcgen/src/base/util/fixed_string_list.dart';

// Type-safe list key for use with AssociatedObject.
final class AssociationListKey<T> {
  static final Map<String, AssociationListKey<dynamic>> _map = {};

  static final AssociationListKey<FixedStringList> choices = AssociationListKey._('CHOICES');
  static final AssociationListKey<Object> add = AssociationListKey._('ADD');

  final String _name;

  AssociationListKey._(this._name) {
    _map[_name.toLowerCase()] = this;
  }

  static AssociationListKey<OT> getKeyFor<OT>(String keyName) {
    final key = _map[keyName.toLowerCase()];
    if (key != null) return key as AssociationListKey<OT>;
    final newKey = AssociationListKey<OT>._(keyName.toUpperCase());
    return newKey;
  }

  T cast(Object obj) => obj as T;

  @override
  String toString() {
    return _map.entries
        .where((e) => e.value == this)
        .map((e) => e.key.toUpperCase())
        .firstOrNull ?? '';
  }
}
