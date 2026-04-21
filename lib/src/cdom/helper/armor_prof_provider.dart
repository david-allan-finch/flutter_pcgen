//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.ArmorProfProvider
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/core/armor_prof.dart';
import 'package:flutter_pcgen/src/cdom/helper/abstract_prof_provider.dart';

// An ArmorProfProvider grants armor proficiencies either by direct ArmorProf
// reference or by Equipment TYPE (e.g. TYPE=Armor.Light).
class ArmorProfProvider extends AbstractProfProvider<ArmorProf> {
  ArmorProfProvider(
    List<CDOMReference<ArmorProf>> profs,
    List<CDOMReference<dynamic>> equipTypes,
  ) : super(profs, equipTypes);

  // Returns true if this provider covers the given equipment's armor
  // proficiency or matches the equipment's type string.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getArmorProf() as ArmorProf) ||
        providesEquipmentType(equipment.getType() as String);
  }

  // Returns "ARMOR", used to build the LST format.
  @override
  String getSubType() => 'ARMOR';
}
