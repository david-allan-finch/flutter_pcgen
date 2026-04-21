//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.DisplayLocation
// Type-safe constant for display location names (e.g. where an ability shows on sheet).
final class DisplayLocation implements Comparable<DisplayLocation> {
  static final Map<String, DisplayLocation> _typeMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  DisplayLocation._(this._name) : _ordinal = _ordinalCount++;

  static DisplayLocation getConstant(String name) {
    return _typeMap.putIfAbsent(name.toLowerCase(), () => DisplayLocation._(name));
  }

  static DisplayLocation valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined Type');
    return result;
  }

  static List<DisplayLocation> getAllConstants() => List.unmodifiable(_typeMap.values);
  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;
  String getComparisonString() => _name.toUpperCase();

  @override
  String toString() => _name;

  @override
  int compareTo(DisplayLocation other) => _name.compareTo(other._name);
}
