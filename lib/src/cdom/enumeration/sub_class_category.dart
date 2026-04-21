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
// Translation of pcgen.cdom.enumeration.SubClassCategory
import '../inst/abstract_category.dart';
import '../../core/sub_class.dart';

// Type-safe constant that also acts as a Category<SubClass>.
final class SubClassCategory extends AbstractCategory<SubClass> {
  static final Map<String, SubClassCategory> _typeMap = {};
  static int _ordinalCount = 0;

  final int _ordinal;

  SubClassCategory._(String name)
      : _ordinal = _ordinalCount++ {
    setName(name);
  }

  static SubClassCategory getConstant(String name) {
    final lookup = name.replaceAll('_', ' ');
    if (lookup.isEmpty) throw ArgumentError('Type Name cannot be zero length');
    return _typeMap.putIfAbsent(lookup.toLowerCase(), () => SubClassCategory._(lookup));
  }

  static SubClassCategory valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError(name);
    return result;
  }

  static List<SubClassCategory>? getAllConstants() {
    if (_typeMap.isEmpty) return null;
    return List.unmodifiable(_typeMap.values);
  }

  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  void setName(String name) {
    // Only allowed during construction (called from constructor)
    super.setName(name);
  }

  @override
  SubClass newInstance() {
    final sc = SubClass();
    sc.setCDOMCategory(this);
    return sc;
  }

  @override
  Type get referenceClass => SubClass;

  @override
  String getReferenceDescription() => 'SubClass Category ${getKeyName()}';

  @override
  String getPersistentFormat() => 'SUBCLASS=${getKeyName()}';
}
