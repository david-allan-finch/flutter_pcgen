// Translation of pcgen.output.factory.FactModelFactory

import '../base/model_factory.dart';
import '../model/fact_facet_model.dart';

/// A ModelFactory that wraps a FactFacet and produces FactFacetModel objects.
class FactModelFactory implements ModelFactory {
  final dynamic _facet;

  FactModelFactory(this._facet);

  @override
  dynamic generate(String charId) => FactFacetModel(_facet, charId);
}
