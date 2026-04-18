// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/GenderFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_item_facet.dart';

/// GenderFacet is a Facet that tracks the Gender of a Player Character.
class GenderFacet extends AbstractItemFacet<CharID, dynamic> {
  dynamic templateFacet; // TemplateFacet

  /// Returns the Gender for the Player Character represented by the given CharID.
  dynamic getGender(CharID id) {
    dynamic g = _findTemplateGender(id);
    if (g == null) {
      g = get(id);
    }
    return g; // null means default Gender
  }

  /// Returns true if the Gender can be set for the Player Character
  /// represented by the given CharID.
  bool canSetGender(CharID id) {
    return _findTemplateGender(id) == null;
  }

  /// Returns the Gender if the Gender has been locked by a PCTemplate
  /// possessed by the Player Character represented by the given CharID.
  dynamic _findTemplateGender(CharID id) {
    dynamic g;
    if (templateFacet == null) return null;
    for (dynamic template in templateFacet.getSet(id)) {
      dynamic lock = template.get('GENDER_LOCK'); // ObjectKey.GENDER_LOCK
      if (lock != null) {
        g = lock;
      }
    }
    return g;
  }

  void setTemplateFacet(dynamic templateFacet) {
    this.templateFacet = templateFacet;
  }

  /// Initializes the connections for GenderFacet to other facets.
  void init() {
    // OutputDB.register("gender", this) - output registration not translated
  }
}
