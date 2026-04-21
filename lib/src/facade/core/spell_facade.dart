//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.facade.core.SpellFacade
import '../../core/character/character_spell.dart';
import '../../core/character/spell_info.dart';
import 'info_facade.dart';

// Facade interface for Spells visible in the UI.
abstract interface class SpellFacade implements InfoFacade {
  String getSchool();
  String getSubschool();
  List<String> getDescriptors();
  String getComponents();
  String getRange();
  String getDuration();
  String getCastTime();
  CharacterSpell? getCharSpell();
  SpellInfo? getSpellInfo();
}
