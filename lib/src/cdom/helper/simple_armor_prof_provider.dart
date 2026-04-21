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
// Translation of pcgen.cdom.helper.SimpleArmorProfProvider
import 'package:flutter_pcgen/src/core/armor_prof.dart';
import 'package:flutter_pcgen/src/cdom/helper/abstract_simple_prof_provider.dart';

// A SimpleArmorProfProvider grants proficiency for a single ArmorProf, and
// also provides equipment-level resolution via getArmorProf().
class SimpleArmorProfProvider extends AbstractSimpleProfProvider<ArmorProf> {
  SimpleArmorProfProvider(ArmorProf proficiency) : super(proficiency);

  // Returns true if the equipment's armor proficiency matches this provider.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getArmorProf() as ArmorProf);
  }

  @override
  int get hashCode => getLstFormat().hashCode;

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      (o is SimpleArmorProfProvider && hasSameProf(o));
}
