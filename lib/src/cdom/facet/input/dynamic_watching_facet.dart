//
// Copyright (c) 2016 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.facet.input.DynamicWatchingFacet
// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/DynamicWatchingFacet.java

import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_sourced_list_facet.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/data_facet_change_listener.dart';

/// DynamicWatchingFacet is a Facet that determines all Dynamic Objects that have
/// been granted to a Player Character.
class DynamicWatchingFacet extends AbstractSourcedListFacet<CharID, dynamic>
    implements DataFacetChangeListener<CharID, dynamic> {
  @override
  void dataAdded(DataFacetChangeEvent<CharID, dynamic> dfce) {
    CharID id = dfce.getCharID();
    dynamic cdo = dfce.getCDOMObject();
    List<dynamic>? granted = cdo.getListFor('GRANTED'); // ListKey.GRANTED
    if (granted == null) {
      return;
    }
    for (dynamic reference in granted) {
      for (dynamic dynamic_ in reference.getContainedObjects()) {
        add(id, dynamic_, cdo);
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, dynamic> dfce) {
    CharID id = dfce.getCharID();
    dynamic cdo = dfce.getCDOMObject();
    List<dynamic>? granted = cdo.getListFor('GRANTED'); // ListKey.GRANTED
    if (granted == null) {
      return;
    }
    for (dynamic reference in granted) {
      for (dynamic dynamic_ in reference.getContainedObjects()) {
        remove(id, dynamic_, cdo);
      }
    }
  }
}
