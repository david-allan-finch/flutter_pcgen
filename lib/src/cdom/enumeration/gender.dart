//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.enumeration.Gender
// Represents genders available in PCGen.
enum Gender {
  male,
  female,
  neuter,
  host,
  unknown;

  static Gender getDefaultValue() => Gender.male;

  static Gender getGenderByName(String name) {
    for (final gender in values) {
      if (gender.name.toLowerCase() == name.toLowerCase()) return gender;
    }
    // Legacy fallback: try display name match (Male, Female, etc.)
    return values.firstWhere(
      (g) => g.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Gender.unknown,
    );
  }

  String getDisplayName() {
    return name[0].toUpperCase() + name.substring(1);
  }
}
