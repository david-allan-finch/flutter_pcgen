//
// Copyright (c) 2016 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.facet.input.DynamicFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/DynamicFacet.java

import '../../../enumeration/char_id.dart';
import '../base/abstract_scope_facet.dart';
import '../event/data_facet_change_event.dart';
import '../event/data_facet_change_listener.dart';

/// DynamicFacet is a Facet that tracks all Dynamic Objects that have been
/// granted to a Player Character.
class DynamicFacet extends AbstractScopeFacet<CharID, dynamic, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  /// Adds the active Dynamic to this facet.
  ///
  /// Triggered when one of the Facets to which DynamicFacet listens fires a
  /// DataFacetChangeEvent to indicate Dynamic was added to a Player Character.
  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    dynamic cdo = dfce.getCDOMObject();
    add(dfce.getCharID(), cdo.getCDOMCategory(), cdo, dfce.getSource());
  }

  /// Removes the no-longer active Dynamic from this facet.
  ///
  /// Triggered when one of the Facets to which DynamicFacet listens fires a
  /// DataFacetChangeEvent to indicate Dynamic was removed from a Player
  /// Character.
  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    dynamic cdo = dfce.getCDOMObject();
    remove(dfce.getCharID(), cdo.getCDOMCategory(), cdo, dfce.getSource());
  }
}
