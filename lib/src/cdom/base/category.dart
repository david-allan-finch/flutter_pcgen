//
// Copyright (c) 2007-18 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.Category
import 'categorized.dart';
import 'loadable.dart';

// ClassIdentity stub - used until ClassIdentity is fully translated
abstract interface class ClassIdentity<T> {
  String getName();
  Type getReferenceClass();
  T newInstance();
  String getReferenceDescription();
  bool isMember(T item);
  String getPersistentFormat();
}

/// Category identifies an object and is used for establishing unique identity
/// of an object. A Category serves as a Category for a particular type of
/// CategorizedCDOMObject.
abstract interface class Category<T extends Categorized<T>>
    implements Loadable, ClassIdentity<T> {
  /// Returns the Parent Category for the current Category. Returns null if
  /// the current Category is a "root" Category.
  Category<T>? getParentCategory();
}
