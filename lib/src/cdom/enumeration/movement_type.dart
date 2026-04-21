//
// Copyright (c) 2019 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.MovementType
// Type-safe constant for movement types (Walk, Fly, Swim, etc.).
class MovementType {
  static final Map<String, MovementType> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  MovementType._(this._name) : _ordinal = _ordinalCount++;

  static MovementType getConstant(String name) {
    final key = name.toLowerCase();
    return _typeMap.putIfAbsent(key, () => MovementType._(name));
  }

  static MovementType valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined MovementType');
    return result;
  }

  static List<MovementType> getAllConstants() => List.unmodifiable(_typeMap.values);

  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  bool operator ==(Object other) => other is MovementType && _name.toLowerCase() == other._name.toLowerCase();

  @override
  int get hashCode => _name.toLowerCase().hashCode;
}
