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
// Translation of pcgen.core.analysis.SubstitutionLevelSupport
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/substitution_class.dart';

// Handles application and qualification checking for substitution class levels.
final class SubstitutionLevelSupport {
  SubstitutionLevelSupport._();

  static void applyLevelArrayModsToLevel(
      SubstitutionClass sc, PCClass aClass, int aLevel, PlayerCharacter aPC) {
    final levelArray = sc.getListFor('SUB_CLASS_LEVEL');
    if (levelArray == null) return;

    final newLevels = [];
    for (final line in levelArray) {
      final aLine = line.lstLine as String;
      final modLevel = int.parse(aLine.substring(0, aLine.indexOf('\t')));
      if (aLevel == modLevel) {
        if (_levelArrayQualifies(aLevel, aPC, aLine, line.source, aClass)) {
          newLevels.add(line);
        }
      }
    }

    if (newLevels.isNotEmpty) {
      // Apply the last qualifying deferred line to aClass at aLevel
      // (requires PCClassLoader.parseLine — stubbed)
    }
  }

  static bool qualifiesForSubstitutionLevel(
      PCClass cl, SubstitutionClass sc, PlayerCharacter aPC, int level) {
    // stub — checks substitution class prerequisites at the given level
    return true;
  }

  static bool _levelArrayQualifies(int level, PlayerCharacter pc, String aLine,
      dynamic tempSource, dynamic source) {
    // stub — parses a dummy class from the LST line and checks qualifies()
    return true;
  }
}
