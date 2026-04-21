//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.equip.EquipmentSelection

/// Represents a selection of equipment items to be added/removed from an equipment set.
class EquipmentSelection {
  final String equipmentSetName;
  final List<EquipmentItem> items;

  const EquipmentSelection({
    required this.equipmentSetName,
    required this.items,
  });
}

class EquipmentItem {
  final String name;
  final int quantity;
  final String? location;

  const EquipmentItem({
    required this.name,
    this.quantity = 1,
    this.location,
  });
}
