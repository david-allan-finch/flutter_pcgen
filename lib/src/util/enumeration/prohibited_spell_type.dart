//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.util.enumeration.ProhibitedSpellType
import 'package:pcgen2/src/cdom/enumeration/list_key.dart';
import 'package:pcgen2/src/cdom/identifier/spell_school.dart';
import 'package:pcgen2/src/core/spell/spell.dart';

enum ProhibitedSpellType {
  alignment('Alignment'),
  descriptor('Descriptor'),
  school('School'),
  subSchool('SubSchool'),
  spell('Spell');

  final String text;

  const ProhibitedSpellType(this.text);

  @override
  String toString() => text;

  List<String> getCheckList(Spell s) {
    return switch (this) {
      ProhibitedSpellType.alignment ||
      ProhibitedSpellType.descriptor =>
        List<String>.of(
            s.getSafeListFor(ListKey.getConstant<String>('SPELL_DESCRIPTOR'))),
      ProhibitedSpellType.school => s
          .getSafeListFor(ListKey.getConstant<SpellSchool>('SPELL_SCHOOL'))
          .map((ss) => ss.toString())
          .toList(),
      ProhibitedSpellType.subSchool => List<String>.of(
          s.getSafeListFor(ListKey.getConstant<String>('SPELL_SUBSCHOOL'))),
      ProhibitedSpellType.spell => [s.getKeyName()],
    };
  }

  int getRequiredCount(List<String> l) {
    return switch (this) {
      ProhibitedSpellType.spell => 1,
      _ => l.length,
    };
  }
}
