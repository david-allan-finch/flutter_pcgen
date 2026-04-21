// *
// Copyright James Dempsey, 2010
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.BodyStructure
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart' as cdom;
import 'character/equip_slot.dart';

// Represents a part of a character's body that can hold equipment (Head, Torso, etc.).
class BodyStructure {
  final String name;
  final bool holdsAnyType;
  final Set<cdom.Type> _forbiddenTypes;
  final List<EquipSlot> _slots = [];

  BodyStructure(this.name, {this.holdsAnyType = false, Set<cdom.Type>? forbiddenTypes})
      : _forbiddenTypes = forbiddenTypes != null ? Set.of(forbiddenTypes) : {};

  String getName() => name;

  void addEquipSlot(EquipSlot slot) => _slots.add(slot);

  List<EquipSlot> getSlots() => List.unmodifiable(_slots);

  bool isForbidden(List<cdom.Type> types) {
    if (_forbiddenTypes.isEmpty) return false;
    return types.any(_forbiddenTypes.contains);
  }

  bool isHoldsAnyType() => holdsAnyType;

  @override
  String toString() => name;
}
