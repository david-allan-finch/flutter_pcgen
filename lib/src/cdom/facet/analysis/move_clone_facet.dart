/*
 * Copyright (c) Thomas Parker, 2019.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

import '../../enumeration/char_id.dart';
import '../base/abstract_sourced_list_facet.dart';
import '../event/data_facet_change_listener.dart';

/// MovementFacet is a Facet that tracks the MoveClone objects that are
/// contained in a Player Character.
class MoveCloneFacet extends AbstractSourcedListFacet
    implements DataFacetChangeListener {
  dynamic consolidationFacet;

  /// Adds to this Facet the MoveClone objects contained within a CDOMObject
  /// granted to the Player Character.
  @override
  void dataAdded(dynamic dfce) {
    final cdo = dfce.getCDOMObject();
    final ml = cdo.getListFor('MOVEMENTCLONE') as List?;
    if (ml != null) {
      addAll(dfce.getCharID() as CharID, ml, cdo);
    }
  }

  /// Removes from this Facet the MoveClone objects contained within a
  /// CDOMObject removed from the Player Character.
  @override
  void dataRemoved(dynamic dfce) {
    removeAll(dfce.getCharID() as CharID, dfce.getCDOMObject());
  }

  void setConsolidationFacet(dynamic consolidationFacet) {
    this.consolidationFacet = consolidationFacet;
  }

  /// Initializes the connections for MoveCloneFacet to other facets.
  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
