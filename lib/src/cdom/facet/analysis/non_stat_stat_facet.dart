/*
 * Copyright (c) James Dempsey 2013
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

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// NonStatStatFacet is a Facet that tracks the Stats that have been locked to
/// non stats on a Player Character.
class NonStatStatFacet extends AbstractSourcedListFacet
    implements DataFacetChangeListener {
  dynamic consolidationFacet;

  /// Adds a PCStat to this facet if the PCStat was set to a non stat by a
  /// CDOMObject which has been added to a Player Character.
  @override
  void dataAdded(dynamic dfce) {
    final cdo = dfce.getCDOMObject();
    final locks = cdo.getListFor('NONSTAT_STATS') as List?;
    if (locks != null) {
      final charID = dfce.getCharID() as CharID;
      for (final ref in locks) {
        add(charID, ref.get(), cdo);
      }
    }
  }

  /// Removes StatLock objects granted by a CDOMObject which has been removed
  /// from a Player Character.
  @override
  void dataRemoved(dynamic dfce) {
    removeAllFromSource(dfce.getCharID() as CharID, dfce.getCDOMObject());
  }

  void setConsolidationFacet(dynamic consolidationFacet) {
    this.consolidationFacet = consolidationFacet;
  }

  /// Initializes the connections for NonStatStatFacet to other facets.
  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
