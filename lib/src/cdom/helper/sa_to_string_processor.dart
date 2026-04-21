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
// Translation of pcgen.cdom.helper.SAtoStringProcessor
import 'package:flutter_pcgen/src/core/player_character.dart';

// Converts a SpecialAbility to its parsed text string for a PlayerCharacter.
class SAtoStringProcessor {
  final PlayerCharacter _pc;

  SAtoStringProcessor(PlayerCharacter pc) : _pc = pc;

  String act(dynamic sa, Object source) =>
      sa.getParsedText(_pc, _pc, source);
}
