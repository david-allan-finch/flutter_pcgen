//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.EquipmentLocation
// Where equipment is worn/carried by a character.
enum EquipmentLocation {
  equippedNeither,
  equippedPrimary,
  equippedSecondary,
  equippedBoth,
  equippedTwoHands,
  equippedTempBonus,
  carriedNeither,
  contained,
  notCarried;

  bool isEquipped() {
    switch (this) {
      case EquipmentLocation.carriedNeither:
      case EquipmentLocation.contained:
      case EquipmentLocation.notCarried:
        return false;
      default:
        return true;
    }
  }

  String getString() {
    switch (this) {
      case EquipmentLocation.equippedNeither: return 'Neither';
      case EquipmentLocation.equippedPrimary: return 'Primary Hand';
      case EquipmentLocation.equippedSecondary: return 'Secondary Hand';
      case EquipmentLocation.equippedBoth: return 'Both Hands';
      case EquipmentLocation.equippedTwoHands: return 'Two Hands';
      case EquipmentLocation.equippedTempBonus: return 'Temp Bonus';
      case EquipmentLocation.carriedNeither: return 'Carried';
      case EquipmentLocation.contained: return 'Contained';
      case EquipmentLocation.notCarried: return 'Not Carried';
    }
  }
}
