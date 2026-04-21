//
// Copyright (c) James Dempsey, 2011.
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
// Translation of pcgen.cdom.facet.fact.ChronicleEntryFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/fact/ChronicleEntryFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_list_facet.dart';

/// ChronicleEntryFacet is a Facet that tracks the chronicle entries that have
/// been entered for a Player Character.
class ChronicleEntryFacet extends AbstractListFacet<CharID, dynamic> {
  @override
  List<dynamic> getCopyForNewOwner(List<dynamic> componentSet) {
    List<dynamic> newCopies = [];
    for (dynamic entry in componentSet) {
      try {
        newCopies.add(entry.clone());
      } catch (e) {
        // Logging.errorPrint equivalent
        print('ChronicleEntryFacet.getCopyForNewOwner failed for $entry: $e');
      }
    }
    return newCopies;
  }

  /// Overrides the default behavior of AbstractListFacet, since we need to
  /// ensure we are storing all chronicle entries (otherwise duplicate blanks
  /// are skipped).
  @override
  List<dynamic> getComponentSet() {
    return [];
  }
}
