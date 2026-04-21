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
