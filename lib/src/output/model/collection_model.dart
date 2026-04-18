// Translation of pcgen.output.model.CollectionModel

/// Output model wrapping a collection of items, iterable in templates.
class CollectionModel<T> implements Iterable<T> {
  final List<T> _items;
  CollectionModel(Iterable<T> items) : _items = List.unmodifiable(items);

  @override
  Iterator<T> get iterator => _items.iterator;

  int get size => _items.length;
}
