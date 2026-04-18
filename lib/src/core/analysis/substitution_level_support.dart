import '../../pc_class.dart';
import '../../player_character.dart';
import '../substitution_class.dart';

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
