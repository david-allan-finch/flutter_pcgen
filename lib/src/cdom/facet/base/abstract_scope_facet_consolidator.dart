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
// Translation of pcgen.cdom.facet.base.AbstractScopeFacetConsolidator
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/scope_facet_change_event.dart';
import 'package:flutter_pcgen/src/cdom/facet/event/scope_facet_change_listener.dart';
import 'package:flutter_pcgen/src/cdom/facet/base/abstract_list_facet.dart';

// Consolidates scope-facet events into a flat list facet.
abstract class AbstractScopeFacetConsolidator<S, D>
    extends AbstractListFacet<CharID, D>
    implements ScopeFacetChangeListener<CharID, S, D> {

  @override
  void dataAdded(ScopeFacetChangeEvent<CharID, S, D> dfce) {
    add(dfce.getCharID(), dfce.getCDOMObject());
  }

  @override
  void dataRemoved(ScopeFacetChangeEvent<CharID, S, D> dfce) {
    remove(dfce.getCharID(), dfce.getCDOMObject());
  }
}
