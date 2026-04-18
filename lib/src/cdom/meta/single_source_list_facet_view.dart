import 'facet_view.dart';

// FacetView backed by an AbstractSingleSourceListFacet.
class SingleSourceListFacetView<T> implements FacetView<T> {
  final dynamic _facet; // AbstractSingleSourceListFacet<T, ?>

  SingleSourceListFacetView(dynamic facet) : _facet = facet;

  @override
  List<T> getSet(dynamic id) =>
      List<T>.from(_facet.getSet(id) as Iterable);

  @override
  List<Object> getSources(dynamic id, T obj) {
    final source = _facet.getSource(id, obj);
    return source != null ? [source] : [];
  }

  @override
  List<Object> getChildren() =>
      List<Object>.from(_facet.getDataFacetChangeListeners() as Iterable);

  @override
  String getDescription() => _facet.toString();

  @override
  bool represents(Object src) => _facet == src;
}
