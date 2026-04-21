//
// Copyright 2002 (C) James Dempsey
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
// Translation of pcgen.core.LevelInfo
// Describes skill cap data and XP requirement associated with a character level.
final class LevelInfo {
  String levelString = '0';
  String maxClassSkillString = '0';
  String maxCrossClassSkillString = '0';
  String minXPString = '0';

  double getMaxClassSkillRanks(int level) {
    try { return double.parse(maxClassSkillString); } catch (_) { return 0; }
  }

  double getMaxCrossClassSkillRanks(int level) {
    try { return double.parse(maxCrossClassSkillString); } catch (_) { return 0; }
  }

  int getMinXP() {
    try { return int.parse(minXPString); } catch (_) { return 0; }
  }
}
