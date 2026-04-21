//
// Copyright (c) Devon Jones, 2012.
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
// Translation of pcgen.cdom.facet.input.AutoLanguageListFacet
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
