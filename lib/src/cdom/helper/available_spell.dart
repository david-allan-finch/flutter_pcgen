//
// Copyright (c) 2014 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.AvailableSpell
import '../base/cdom_list.dart';
import '../base/concrete_prereq_object.dart';
import '../../core/spell/spell.dart';

// Associates a spell with a spell list and level — used to track available spells.
class AvailableSpell extends ConcretePrereqObject {
  final CDOMList<Spell> spelllist;
  final Spell spell;
  final int level;

  AvailableSpell(this.spelllist, this.spell, this.level);
}
