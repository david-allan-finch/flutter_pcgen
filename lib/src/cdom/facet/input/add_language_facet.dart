//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.facet.input.AddLanguageFacet
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
