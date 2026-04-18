// Translation of pcgen.output.factory.ItemModelFactory

import '../base/model_factory.dart';
import '../model/item_facet_model.dart';

/// A ModelFactory that wraps an ItemFacet and produces ItemFacetModel objects.
class ItemModelFactory implements ModelFactory {
  final dynamic _facet;

  ItemModelFactory(this._facet);

  @override
  dynamic generate(String charId) => ItemFacetModel(_facet, charId);
}
