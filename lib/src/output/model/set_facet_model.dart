// Translation of pcgen.output.model.SetFacetModel

/// Output model for a SetFacet value — provides an iterable collection.
class SetFacetModel<T> implements Iterable<T> {
  final dynamic _facet;
  final String _charId;

  SetFacetModel(this._facet, this._charId);

  Iterable<T> get _items =>
      (_facet?.getSet(_charId) as Iterable<T>?) ?? const [];

  @override
  Iterator<T> get iterator => _items.iterator;
}
