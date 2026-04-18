// Interface for a view into a facet's data for a character.
abstract interface class FacetView<T> {
  List<T> getSet(dynamic id); // CharID
  List<Object> getSources(dynamic id, T obj);
  List<Object> getChildren();
  String getDescription();
  bool represents(Object src);
}
