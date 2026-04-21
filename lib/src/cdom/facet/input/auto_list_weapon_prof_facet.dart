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
// Translation of pcgen.cdom.facet.input.AutoListWeaponProfFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/AutoListWeaponProfFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';

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
