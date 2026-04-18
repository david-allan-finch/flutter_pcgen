import '../../core/language.dart';
import '../../core/pc_class.dart';
import '../../core/skill.dart';

// Transfer object recording skill rank additions for a kit.
class KitSkillAdd {
  final Skill _skill;
  final double _ranks;
  final double _cost;
  final List<Language> _languages;
  final PCClass _pcClass;

  KitSkillAdd(this._skill, this._ranks, this._cost, this._languages, this._pcClass);

  Skill getSkill() => _skill;
  double getRanks() => _ranks;
  double getCost() => _cost;
  List<Language> getLanguages() => _languages;
  PCClass getPCClass() => _pcClass;
}
