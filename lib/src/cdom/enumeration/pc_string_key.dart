//
// Copyright 2005-15 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.PCStringKey
// Type-safe enumeration of legal String characteristics of a PC.
enum PCStringKey {
  assets, bio, birthplace, birthday, catchphrase, city, companions,
  description, eyeColor, gmNotes, handed, interests, location, magic,
  name, personality1, personality2, phobias, playersName, residence,
  speechTendency, tabName,
  // Internal keys
  fileName, portraitPath, spellBookAutoAddKnown, currentEquipSetName;

  static PCStringKey getStringKey(String s) {
    return PCStringKey.values.firstWhere(
      (e) => e.name.toUpperCase() == s.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown PCStringKey: $s'),
    );
  }
}
