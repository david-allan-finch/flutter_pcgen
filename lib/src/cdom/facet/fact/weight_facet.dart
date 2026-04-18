// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/WeightFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_item_facet.dart';

/// WeightFacet is a Facet that tracks the Player Character's weight. Note that
/// this weight is the actual character weight, not the character plus the
/// character's equipment.
class WeightFacet extends AbstractItemFacet<CharID, int> {
  /// Returns the weight for the Player Character represented by the given
  /// CharID. Returns 0 if not set.
  int getWeight(CharID id) {
    int? weight = get(id);
    return weight ?? 0;
  }
}
