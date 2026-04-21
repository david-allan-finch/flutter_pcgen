//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.filter.FilterUtilities

import 'filter.dart';

/// Utility methods for working with filters.
class FilterUtilities {
  FilterUtilities._();

  /// Creates an AND filter from two filters.
  static Filter<T> and<T>(Filter<T> a, Filter<T> b) => AndFilter<T>([a, b]);

  /// Creates an OR filter from two filters.
  static Filter<T> or<T>(Filter<T> a, Filter<T> b) => OrFilter<T>([a, b]);

  /// Creates a NOT filter.
  static Filter<T> not<T>(Filter<T> f) => NotFilter<T>(f);

  /// Creates a text-search filter that calls toString() on each element.
  static Filter<T> textSearch<T>(String query) {
    final lower = query.toLowerCase();
    return _TextFilter(lower);
  }
}

class _TextFilter<T> implements Filter<T> {
  final String _query;
  _TextFilter(this._query);
  @override
  bool accept(T element, dynamic context) {
    if (_query.isEmpty) return true;
    return element.toString().toLowerCase().contains(_query);
  }
}
