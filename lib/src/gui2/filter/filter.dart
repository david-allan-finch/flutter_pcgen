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
// Translation of pcgen.gui2.filter.Filter

/// Interface for filtering elements of type T.
abstract class Filter<T> {
  bool accept(T element, dynamic context);
}

/// A filter that accepts all elements.
class AcceptAllFilter<T> implements Filter<T> {
  const AcceptAllFilter();
  @override
  bool accept(T element, dynamic context) => true;
}

/// A filter composed of multiple AND'd sub-filters.
class AndFilter<T> implements Filter<T> {
  final List<Filter<T>> _filters;
  AndFilter(this._filters);
  @override
  bool accept(T element, dynamic context) =>
      _filters.every((f) => f.accept(element, context));
}

/// A filter composed of multiple OR'd sub-filters.
class OrFilter<T> implements Filter<T> {
  final List<Filter<T>> _filters;
  OrFilter(this._filters);
  @override
  bool accept(T element, dynamic context) =>
      _filters.any((f) => f.accept(element, context));
}

/// A filter that negates another filter.
class NotFilter<T> implements Filter<T> {
  final Filter<T> _delegate;
  NotFilter(this._delegate);
  @override
  bool accept(T element, dynamic context) => !_delegate.accept(element, context);
}
