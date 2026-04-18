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
