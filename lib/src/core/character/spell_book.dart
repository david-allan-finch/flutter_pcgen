//
// Copyright 2006 (C) James Dempsey <jdempsey@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.character.SpellBook
import '../equipment.dart';

// Contains details of a prepared spell list or spell book.
class SpellBook {
  static const int typeKnownSpells = 1;
  static const int typePreparedList = 2;
  static const int typeSpellBook = 3;
  static const int typeInnateSpells = 4;

  String name;
  int type;
  int numPages = 0;
  int numPagesUsed = 0;
  int numSpells = 0;
  String? pageFormula; // formula string (was pcgen Formula)
  String? description;
  Equipment? equip;

  SpellBook(this.name, this.type);

  String getTypeName() => switch (type) {
    typeKnownSpells => 'Known Spell List',
    typePreparedList => 'Prepared Spell List',
    typeSpellBook => 'Spell Book',
    typeInnateSpells => 'Innate Spell List',
    _ => 'Unknown spell list type: $type',
  };

  void setEquip(Equipment e) {
    equip = e;
    numPages = e.getSafe<int>('NUM_PAGES') ?? 0;
    pageFormula = e.getSafe<String>('PAGE_USAGE');
  }

  SpellBook clone() {
    final c = SpellBook(name, type)
      ..numPages = numPages
      ..numPagesUsed = numPagesUsed
      ..numSpells = numSpells
      ..pageFormula = pageFormula
      ..description = description
      ..equip = equip?.clone();
    return c;
  }

  @override
  String toString() {
    final sb = StringBuffer(name);
    if (type == typeSpellBook) {
      sb.write(' [$numPagesUsed/$numPages]');
    }
    return sb.toString();
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is! SpellBook) return false;
    return name == o.name &&
        type == o.type &&
        numPages == o.numPages &&
        numPagesUsed == o.numPagesUsed &&
        numSpells == o.numSpells &&
        pageFormula == o.pageFormula &&
        description == o.description &&
        equip == o.equip;
  }
}
