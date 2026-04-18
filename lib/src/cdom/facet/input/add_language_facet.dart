// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AddLanguageFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';

/// AddLanguageFacet tracks the Languages added to a Player Character by the
/// ADD:LANGUAGE token.
class AddLanguageFacet extends AbstractSourcedListFacet<CharID, dynamic> {
  dynamic languageFacet; // LanguageFacet

  void setLanguageFacet(dynamic languageFacet) {
    this.languageFacet = languageFacet;
  }

  void init() {
    addDataFacetChangeListener(languageFacet);
    // CorePerspectiveDB.register(CorePerspective.LANGUAGE, FacetBehavior.INPUT, this)
  }

  String getIdentity() {
    return 'ADD:LANGUAGE';
  }
}
