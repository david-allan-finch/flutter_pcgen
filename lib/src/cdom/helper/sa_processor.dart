//
// Copyright (c) Thomas Parker, 2012.
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
// Translation of pcgen.cdom.helper.SAProcessor
import '../../core/player_character.dart';
import '../../core/special_ability.dart';

// Processes a SpecialAbility, resolving %CHOICE substitutions from the PC.
class SAProcessor {
  final PlayerCharacter _pc;

  SAProcessor(PlayerCharacter pc) : _pc = pc;

  SpecialAbility act(SpecialAbility sa, Object source) {
    final key = sa.getKeyName();
    final idx = key.indexOf('%CHOICE');
    if (idx == -1) return sa;

    final sb = StringBuffer(key.substring(0, idx));
    if (source is dynamic && _pc.hasAssociations(source)) {
      final assocList = List<String>.from(_pc.getAssociationList(source))..sort();
      sb.write(assocList.join(', '));
    } else {
      sb.write('<undefined>');
    }
    sb.write(key.substring(idx + 7));
    return SpecialAbility(sb.toString(), sa.getSADesc());
  }
}
