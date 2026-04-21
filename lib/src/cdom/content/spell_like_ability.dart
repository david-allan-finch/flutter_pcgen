//
// Copyright 2012 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.content.SpellLikeAbility
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';

// Represents a spell-like ability with cast times, caster level, DC, and book info.
class SpellLikeAbility extends ConcretePrereqObject {
  final Spell spell;
  final String castTimes; // formula string
  final String castTimeUnit;
  final String fixedCasterLevel;
  final String dc;
  final String book;
  final String qualifiedKey;

  SpellLikeAbility(this.spell, this.castTimes, this.castTimeUnit,
      this.book, this.fixedCasterLevel, this.dc, this.qualifiedKey);

  Spell getSpell() => spell;
  String getCastTimes() => castTimes;
  String getCastTimeUnit() => castTimeUnit;
  String getFixedCasterLevel() => fixedCasterLevel;
  String getDC() => dc;
  String getSpellBook() => book;
  String getQualifiedKey() => qualifiedKey;
}
