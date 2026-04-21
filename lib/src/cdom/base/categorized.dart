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
// Translation of pcgen.cdom.base.Categorized
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

/// Categorized represents an object which can possess a Category object.
/// This Category is used for establishing unique identity of an object.
abstract interface class Categorized<T extends Categorized<T>>
    implements Loadable {
  /// Returns the Category of the Categorized object.
  Category<T>? getCDOMCategory();

  /// Sets the Category of the Categorized object.
  void setCDOMCategory(Category<T> category);

  /// Returns the ClassIdentity for this Categorized object (its category).
  ClassIdentity<Loadable>? getClassIdentity() => getCDOMCategory();
}
