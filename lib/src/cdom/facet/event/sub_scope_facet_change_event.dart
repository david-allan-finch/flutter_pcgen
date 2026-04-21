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
// Translation of pcgen.cdom.facet.event.SubScopeFacetChangeEvent
import 'package:flutter_pcgen/src/cdom/enumeration/char_id.dart';

// Event fired when a two-scope facet's data changes.
class SubScopeFacetChangeEvent<S1, S2, T> {
  static const int dataAdded = 0;
  static const int dataRemoved = 1;

  final int eventID;
  final CharID charID;
  final S1 scope1;
  final S2 scope2;
  final T node;
  final Object source;

  SubScopeFacetChangeEvent(
      this.charID, this.scope1, this.scope2, this.node, this.source, this.eventID);

  CharID getCharID() => charID;
  S1 getScope1() => scope1;
  S2 getScope2() => scope2;
  T getCDOMObject() => node;
  int getEventType() => eventID;
  Object getSource() => source;
}
