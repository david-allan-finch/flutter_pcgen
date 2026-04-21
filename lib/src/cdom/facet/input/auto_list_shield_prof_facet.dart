//
// Copyright (c) Thomas Parker, 2010.
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
// Translation of pcgen.cdom.facet.input.AutoListShieldProfFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AutoListShieldProfFacet.java

import '../../../enumeration/char_id.dart';

/// AutoListShieldProfFacet is a Facet that tracks the ShieldProfs that have been
/// granted to a Player Character by AUTO:SHIELDPROF|%LIST and converts them to
/// ProfProvider objects.
class AutoListShieldProfFacet {
  dynamic shieldProfProviderFacet; // ShieldProfProviderFacet

  // AbstractItemConvertingFacet state
  final Map<CharID, Map<dynamic, dynamic>> _cache = {};

  void setShieldProfProviderFacet(dynamic shieldProfProviderFacet) {
    this.shieldProfProviderFacet = shieldProfProviderFacet;
  }

  void init() {
    addDataFacetChangeListener(shieldProfProviderFacet);
    // CorePerspectiveDB.register(CorePerspective.SHIELDPROF, FacetBehavior.INPUT, this)
  }

  /// Converts a ShieldProf into a ProfProvider<ShieldProf>.
  dynamic convert(dynamic ap) {
    // return new SimpleShieldProfProvider(ap)
    return ap; // stub: wrap in provider
  }

  String getIdentity() {
    return 'AUTO:SHIELDPROF|%LIST';
  }

  void addDataFacetChangeListener(dynamic listener) {
    // To be implemented by event infrastructure
  }
}
