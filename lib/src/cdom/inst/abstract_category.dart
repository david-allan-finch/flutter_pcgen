//
// Copyright (c) 2016-18 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.inst.AbstractCategory
import '../base/categorized.dart';
import '../base/category.dart';

// Base class for Category objects that categorize Categorized objects.
abstract class AbstractCategory<T extends Categorized<T>> implements Category<T> {
  String? _categoryName;
  String? _sourceURI;

  @override
  Category<T>? getParentCategory() => null;

  @override
  String getKeyName() => _categoryName ?? '';

  @override
  String? getDisplayName() => _categoryName;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  void setName(String name) { _categoryName = name; }

  @override
  bool isMember(T item) => item.getCDOMCategory() == this;

  @override
  String toString() => _categoryName ?? '';

  @override
  int get hashCode => (_categoryName ?? '').hashCode ^ runtimeType.hashCode;

  @override
  bool operator ==(Object o) =>
      runtimeType == o.runtimeType &&
      o is AbstractCategory<T> &&
      _categoryName == o._categoryName;
}
