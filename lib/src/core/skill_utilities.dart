import 'level_info.dart';
import 'player_character.dart';

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
