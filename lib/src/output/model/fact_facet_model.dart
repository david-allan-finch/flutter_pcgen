// Translation of pcgen.output.model.FactFacetModel

/// Output model for a Fact facet value for a given CharID.
class FactFacetModel {
  final dynamic _facet;
  final String _charId;

  FactFacetModel(this._facet, this._charId);

  dynamic get value => _facet?.get(_charId);

  @override
  String toString() => value?.toString() ?? '';
}
