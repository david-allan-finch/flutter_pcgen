//
// Copyright 2008 (C) James Dempsey
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
// Translation of pcgen.cdom.enumeration.MapKey
// Typesafe key for Map storage in CDOMObject.
class MapKey<K, V> {
  static final Map<String, MapKey<dynamic, dynamic>> _registry = {};

  final String? _name;

  MapKey._([this._name]);

  // Named factory for registration
  static MapKey<K, V> named<K, V>(String name) {
    final existing = _registry[name];
    if (existing != null) return existing as MapKey<K, V>;
    final key = MapKey<K, V>._(name);
    _registry[name] = key;
    return key;
  }

  @override
  String toString() => _name ?? 'MapKey<$K,$V>';
}
