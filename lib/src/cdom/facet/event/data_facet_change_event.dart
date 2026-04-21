//
// Copyright (c) Thomas Parker, 2009.
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
// Translation of pcgen.cdom.facet.event.DataFacetChangeEvent
import 'package:flutter_pcgen/src/cdom/base/pcgen_identifier.dart';

// Event fired when a facet's data changes for a given PCGenIdentifier.
class DataFacetChangeEvent<IDT extends PCGenIdentifier, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final IDT charID;
  final T node;
  final Object source;

  DataFacetChangeEvent(this.charID, this.node, this.source, this.eventID);

  IDT getCharID() => charID;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
