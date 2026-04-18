// Facet that stores a set of items per identifier.
abstract interface class SetFacet<IDT, T> {
  List<T> getSet(IDT id);
  int getCount(IDT id);
}
