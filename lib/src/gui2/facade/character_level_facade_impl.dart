// *
// Copyright James Dempsey, 2010
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
// Translation of pcgen.gui2.facade.CharacterLevelFacadeImpl

import 'package:flutter_pcgen/src/facade/core/character_level_facade.dart';

/// Concrete implementation of CharacterLevelFacade wrapping a PCGen character level.
class CharacterLevelFacadeImpl implements CharacterLevelFacade {
  final dynamic _level;

  CharacterLevelFacadeImpl(this._level);

  @override
  dynamic getCharClass() => _level?.charClass;

  @override
  int getLevel() => (_level?.level as int?) ?? 0;

  @override
  String toString() {
    final cls = getCharClass();
    return '${cls?.toString() ?? 'Unknown'} ${getLevel()}';
  }
}
