// Translation of pcgen.output.model.ItemFacetModel

/// Output model for an ItemFacet value for a given CharID.
class ItemFacetModel {
  final dynamic _facet;
  final String _charId;

  ItemFacetModel(this._facet, this._charId);

  dynamic get value => _facet?.get(_charId);

  @override
  String toString() => value?.toString() ?? '';
}
