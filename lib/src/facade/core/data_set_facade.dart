import '../../core/ability_category.dart';
import '../../core/campaign.dart';
import '../../core/deity.dart';
import '../../core/game_mode.dart';
import '../../core/kit.dart';
import '../../core/pc_alignment.dart';
import '../../core/pc_class.dart';
import '../../core/pc_stat.dart';
import '../../core/pc_template.dart';
import '../../core/race.dart';
import '../../core/skill.dart';
import 'ability_facade.dart';
import 'equipment_facade.dart';

// Provides access to all loaded game data for UI browsing.
abstract interface class DataSetFacade {
  Map<AbilityCategory, List<AbilityFacade>> getAbilities();
  List<AbilityFacade> getPrereqAbilities(AbilityFacade ability);
  List<Skill> getSkills();
  List<Race> getRaces();
  List<PCClass> getClasses();
  List<Deity> getDeities();
  List<PCTemplate> getTemplates();
  List<Campaign> getCampaigns();
  GameMode getGameMode();
  List<PCAlignment> getAlignments();
  List<PCStat> getStats();
  Skill? getSpeakLanguageSkill();
  List<EquipmentFacade> getEquipment();
  void addEquipment(EquipmentFacade equip);
  List<Kit> getKits();
}
