import 'facet_view.dart';

// FacetView backed by an AbstractSourcedListFacet.
class ListFacetView<T> implements FacetView<T> {
  final dynamic _facet; // AbstractSourcedListFacet<CharID, T>

  ListFacetView(dynamic facet) : _facet = facet;

  @override
  List<T> getSet(dynamic id) =>
      List<T>.from(_facet.getSet(id) as Iterable);

  @override
  List<Object> getSources(dynamic id, T obj) =>
      List<Object>.from(_facet.getSources(id, obj) as Iterable);

  @override
  List<Object> getChildren() =>
      List<Object>.from(_facet.getDataFacetChangeListeners() as Iterable);

  @override
  String getDescription() => _facet.toString();

  @override
  bool represents(Object src) => _facet == src;
}
