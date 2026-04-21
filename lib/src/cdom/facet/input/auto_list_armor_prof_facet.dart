//
// Copyright (c) Thomas Parker, 2010-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.facet.input.AutoListArmorProfFacet
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
