import 'facet_view.dart';

// Holds a source-destination pair for ConvertingFacetView display.
class SourceDest {
  final Object _source;
  final Object? _dest;

  SourceDest(Object source, Object? dest)
      : _source = source,
        _dest = dest;

  Object getSource() => _source;
  Object? getDest() => _dest;

  @override
  String toString() => '$_source → $_dest';
}

// FacetView backed by an AbstractItemConvertingFacet.
class ConvertingFacetView<S, D> implements FacetView<Object> {
  final dynamic _facet; // AbstractItemConvertingFacet<S, D>

  ConvertingFacetView(dynamic facet) : _facet = facet;

  @override
  List<Object> getSet(dynamic id) {
    final sources = _facet.getSourceObjects(id) as Iterable;
    return sources.map<Object>((src) {
      final dest = _facet.getResultFor(id, src);
      return SourceDest(src as Object, dest);
    }).toList();
  }

  @override
  List<Object> getSources(dynamic id, Object obj) =>
      List<Object>.from(_facet.getSourcesFor(id, (obj as SourceDest).getSource()) as Iterable);

  @override
  List<Object> getChildren() =>
      List<Object>.from(_facet.getDataFacetChangeListeners() as Iterable);

  @override
  String getDescription() => _facet.toString();

  @override
  bool represents(Object src) => _facet == src;
}
