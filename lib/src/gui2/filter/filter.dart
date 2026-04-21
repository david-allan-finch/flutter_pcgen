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
