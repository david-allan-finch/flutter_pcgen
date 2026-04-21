//
// Copyright (c) 2006 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.Region
// Type-safe constant for character regions; NONE is a pre-defined constant.
final class Region implements Comparable<Region> {
  static final Map<String, Region> _typeMap = {};
  static int _ordinalCount = 0;

  static final Region none = Region._('None');

  final String _name;
  final int _ordinal;

  Region._(this._name) : _ordinal = _ordinalCount++ {
    _typeMap[_name.toLowerCase()] = this;
  }

  static Region getConstant(String name) {
    return _typeMap.putIfAbsent(name.toLowerCase(), () => Region._(name));
  }

  static Region valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined Region');
    return result;
  }

  static List<Region> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  int compareTo(Region other) => _name.toLowerCase().compareTo(other._name.toLowerCase());
}
