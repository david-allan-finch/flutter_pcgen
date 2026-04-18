import '../../core/player_character.dart';

// Method of calculating Armor Check Penalty for a skill.
enum SkillArmorCheck {
  none,
  yes,
  nonProf,
  double_,
  weight;

  int calculateBonus(PlayerCharacter pc) {
    switch (this) {
      case SkillArmorCheck.none:
        return 0;
      case SkillArmorCheck.yes:
        return pc.getArmorCheckPenalty();
      case SkillArmorCheck.nonProf:
        return pc.getArmorCheckPenaltyNonProf();
      case SkillArmorCheck.double_:
        return pc.getArmorCheckPenalty() * 2;
      case SkillArmorCheck.weight:
        return -(pc.getTotalWeight() / 5.0).toInt();
    }
  }
}
