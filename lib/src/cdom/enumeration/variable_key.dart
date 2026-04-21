//
// Copyright (c) 2007 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.VariableKey
import '../../base/util/case_insensitive_map.dart';

// Typesafe constant for variable (DEFINE:) characteristics of a CDOMObject.
class VariableKey {
  static CaseInsensitiveMap<VariableKey>? _typeMap;
  static int _ordinalCount = 0;

  final String _fieldName;
  final int ordinal;

  VariableKey._(this._fieldName) : ordinal = _ordinalCount++;

  @override
  String toString() => _fieldName;

  static CaseInsensitiveMap<VariableKey> get _map {
    _typeMap ??= CaseInsensitiveMap();
    return _typeMap!;
  }

  static VariableKey getConstant(String name) {
    final existing = _map[name];
    if (existing != null) return existing;
    final key = VariableKey._(name);
    _map[name] = key;
    return key;
  }

  static VariableKey valueOf(String name) {
    final key = _map[name];
    if (key == null) throw ArgumentError('$name is not a previously defined VariableKey');
    return key;
  }

  static Iterable<VariableKey> getAllConstants() =>
      List.unmodifiable(_map.values());

  static void clearConstants() => _map.clear();
}
