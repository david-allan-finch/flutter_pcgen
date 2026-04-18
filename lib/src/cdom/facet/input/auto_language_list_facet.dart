// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AutoLanguageListFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';

/// AutoLanguageListFacet is a Facet that tracks the Languages that have been
/// granted to a Player Character through the AUTO:LANG|%LIST token.
class AutoLanguageListFacet extends AbstractSourcedListFacet<CharID, dynamic> {
  dynamic languageFacet; // LanguageFacet

  void setLanguageFacet(dynamic languageFacet) {
    this.languageFacet = languageFacet;
  }

  void init() {
    addDataFacetChangeListener(languageFacet);
    // CorePerspectiveDB.register(CorePerspective.LANGUAGE, FacetBehavior.INPUT, this)
  }

  String getIdentity() {
    return 'AUTO:LANG|%LIST';
  }
}
