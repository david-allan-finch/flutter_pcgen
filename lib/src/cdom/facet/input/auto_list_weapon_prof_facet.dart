// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AutoListWeaponProfFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';

/// AutoListWeaponProfFacet is a Facet that tracks the WeaponProfs that have been
/// granted to a Player Character via AUTO:WEAPONPROF.
class AutoListWeaponProfFacet extends AbstractSourcedListFacet<CharID, dynamic> {
  dynamic weaponProfFacet; // WeaponProfFacet

  void setWeaponProfFacet(dynamic weaponProfFacet) {
    this.weaponProfFacet = weaponProfFacet;
  }

  void init() {
    addDataFacetChangeListener(weaponProfFacet);
  }
}
