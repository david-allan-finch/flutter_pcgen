//
// Copyright (c) Thomas Parker, 2013.
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
// Translation of pcgen.cdom.facet.event.ScopeFacetChangeEvent
import '../../base/pcgen_identifier.dart';

// Event fired when a scope-keyed facet's data changes.
class ScopeFacetChangeEvent<IDT extends PCGenIdentifier, S, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final IDT charID;
  final S scope;
  final T node;
  final Object source;

  ScopeFacetChangeEvent(
      this.charID, this.scope, this.node, this.source, this.eventID);

  IDT getCharID() => charID;
  S getScope() => scope;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
