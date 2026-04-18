import '../../core/skill.dart';

// Holds a skill, the situation name, and the bonus value for that situation.
class SkillSituation {
  final Skill _skill;
  final String _situation;
  final double _bonus;

  SkillSituation(Skill sk, String sit, double sitbonus)
      : _skill = sk,
        _situation = sit,
        _bonus = sitbonus;

  Skill getSkill() => _skill;
  String getSituation() => _situation;
  double getSituationBonus() => _bonus;
}
