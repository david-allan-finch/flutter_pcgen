// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AutoListArmorProfFacet.java

import '../../../enumeration/char_id.dart';

/// AutoListArmorProfFacet is a Facet that tracks the ArmorProfs that have been
/// granted to a Player Character by AUTO:ARMORPROF|%LIST and converts them to
/// ProfProvider objects.
class AutoListArmorProfFacet {
  dynamic armorProfProviderFacet; // ArmorProfProviderFacet

  // AbstractItemConvertingFacet state
  final Map<CharID, Map<dynamic, dynamic>> _cache = {};

  void setArmorProfProviderFacet(dynamic armorProfProviderFacet) {
    this.armorProfProviderFacet = armorProfProviderFacet;
  }

  void init() {
    addDataFacetChangeListener(armorProfProviderFacet);
    // CorePerspectiveDB.register(CorePerspective.ARMORPROF, FacetBehavior.INPUT, this)
  }

  /// Converts an ArmorProf into a ProfProvider<ArmorProf>.
  dynamic convert(dynamic ap) {
    // return new SimpleArmorProfProvider(ap)
    return ap; // stub: wrap in provider
  }

  String getIdentity() {
    return 'AUTO:ARMORPROF|%LIST';
  }

  void addDataFacetChangeListener(dynamic listener) {
    // To be implemented by event infrastructure
  }
}
