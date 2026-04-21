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
// Translation of pcgen.cdom.enumeration.AspectName
// Type-safe constant for Ability Aspect names.
final class AspectName implements Comparable<AspectName> {
  static final Map<String, AspectName> _nameMap = {};
  static int _ordinalCount = 0;

  final String _name;
  final int _ordinal;

  AspectName._(this._name) : _ordinal = _ordinalCount++;

  static AspectName getConstant(String name) {
    return _nameMap.putIfAbsent(name.toLowerCase(), () => AspectName._(name));
  }

  static AspectName valueOf(String name) {
    final result = _nameMap[name.toLowerCase()];
    if (result == null) throw ArgumentError('$name is not a previously defined AspectName');
    return result;
  }

  static List<AspectName> getAllConstants() {
    if (_nameMap.isEmpty) return [];
    return List.unmodifiable(_nameMap.values);
  }

  static void clearConstants() { _nameMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  String toString() => _name;

  @override
  int compareTo(AspectName other) => _name.compareTo(other._name);

  @override
  bool operator ==(Object other) => other is AspectName && other._ordinal == _ordinal;

  @override
  int get hashCode => _ordinal;
}
