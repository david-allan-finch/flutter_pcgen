// ItemFacet stores a single item per identifier. A null return is legal if no
// item has been set for the given identifier.
abstract interface class ItemFacet<IDT, T> {
  T? get(IDT id);
}
