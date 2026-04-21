//
// Copyright (c) Thomas Parker, 2014.
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
// Translation of pcgen.cdom.facet.event.AssociationChangeEvent
// Event fired when an association bonus value changes for a character.
class AssociationChangeEvent {
  final Object source;
  final dynamic charID;
  final dynamic associationKey;
  final dynamic oldValue;
  final dynamic newValue;

  AssociationChangeEvent(this.source, this.charID, this.associationKey,
      this.oldValue, this.newValue);

  Object getSource() => source;
  dynamic getCharID() => charID;
  dynamic getAssociationKey() => associationKey;
  dynamic getOldValue() => oldValue;
  dynamic getNewValue() => newValue;
}
