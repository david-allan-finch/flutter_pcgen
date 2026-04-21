//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.character.Follower
import '../race.dart';

// Represents a companion/familiar/mount linked to a PlayerCharacter.
final class Follower implements Comparable<Object> {
  String fileName;
  String name;
  Race? race;
  String type; // CompanionList name (e.g. "Familiar", "Mount", "Follower")
  int usedHD = 0;
  int adjustment = 0;

  Follower(this.fileName, this.name, this.type);

  @override
  int compareTo(Object obj) {
    final aF = obj as Follower;
    return fileName.compareTo(aF.fileName);
  }

  @override
  String toString() => name;

  Follower clone() => Follower(fileName, name, type)
    ..race = race
    ..usedHD = usedHD
    ..adjustment = adjustment;
}
