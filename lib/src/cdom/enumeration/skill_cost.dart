import '../../core/globals.dart';

// Holds the Skill Costs in type-safe form.
enum SkillCost {
  classSkill,
  crossClass,
  exclusive;

  int getCost() {
    switch (this) {
      case SkillCost.classSkill:
        return Globals.gameMode.skillCostClass;
      case SkillCost.crossClass:
        return Globals.gameMode.skillCostCrossClass;
      case SkillCost.exclusive:
        return Globals.gameMode.skillCostExclusive;
    }
  }
}
