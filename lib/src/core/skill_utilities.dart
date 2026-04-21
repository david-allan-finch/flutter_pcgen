//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.SkillUtilities
import 'package:flutter_pcgen/src/core/level_info.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';

final class SkillUtilities {
  SkillUtilities._();

  // Returns the maximum class-skill ranks allowed at the given level.
  static double maxClassSkillForLevel(int level, PlayerCharacter pc) {
    final LevelInfo? info = pc.getXPTableLevelInfo(level);
    if (info != null) return info.getMaxClassSkillRank(level, pc);
    return 0.0;
  }

  // Returns the maximum cross-class skill ranks allowed at the given level.
  static double maxCrossClassSkillForLevel(int level, PlayerCharacter pc) {
    final LevelInfo? info = pc.getXPTableLevelInfo(level);
    if (info != null) return info.getMaxCrossClassSkillRank(level, pc);
    return 0.0;
  }
}
