// Translation of pcgen.output.factory.SetModelFactory

import '../base/model_factory.dart';
import '../model/set_facet_model.dart';

/// A ModelFactory that wraps a SetFacet and produces SetFacetModel objects.
class SetModelFactory implements ModelFactory {
  final dynamic _facet;

  SetModelFactory(this._facet);

  @override
  dynamic generate(String charId) => SetFacetModel(_facet, charId);
}
