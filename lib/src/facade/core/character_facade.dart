import '../../core/ability.dart';
import '../../core/ability_category.dart';
import '../../core/deity.dart';
import '../../core/domain.dart';
import '../../core/gear_buy_sell_scheme.dart';
import '../../core/language.dart';
import '../../core/pc_alignment.dart';
import '../../core/pc_class.dart';
import '../../core/pc_stat.dart';
import '../../core/pc_template.dart';
import '../../core/player_character.dart';
import '../../core/qualified_object.dart';
import '../../core/race.dart';
import 'ability_facade.dart';
import 'data_set_facade.dart';
import 'equipment_facade.dart';

// The primary facade interface between the core and UI layers for a character.
// All mutable state goes through this interface to enable reactive UI updates.
abstract interface class CharacterFacade {
  // -- Identity --
  String getName();
  void setName(String name);
  String getPlayersName();
  void setPlayersName(String name);
  String getTabName();
  void setTabName(String name);
  String? getFilePath();
  void setFilePath(String? path);

  // -- Race / Alignment / Basics --
  Race? getRace();
  void setRace(Race race);
  PCAlignment? getAlignment();
  void setAlignment(PCAlignment alignment);
  String getGender();
  void setGender(String gender);
  String getHandedness();
  void setHandedness(String handed);

  // -- Stats --
  int getScoreBase(PCStat stat);
  void setScoreBase(PCStat stat, int score);
  int getModTotal(PCStat stat);
  int getScoreRaceBonus(PCStat stat);
  int getScoreOtherBonus(PCStat stat);
  String getScoreTotalString(PCStat stat);

  // -- Class levels --
  void addCharacterLevels(List<PCClass> classes);
  void removeCharacterLevels(int levels);
  int getClassLevel(PCClass c);

  // -- Abilities --
  void addAbility(AbilityCategory category, AbilityFacade ability);
  void removeAbility(AbilityCategory category, AbilityFacade ability);
  List<AbilityFacade> getAbilities(AbilityCategory category);
  List<AbilityCategory> getActiveAbilityCategories();
  int getTotalSelections(AbilityCategory category);
  int getRemainingSelections(AbilityCategory category);
  void setRemainingSelection(AbilityCategory category, int remaining);

  // -- Deity / Domains --
  Deity? getDeity();
  void setDeity(Deity deity);
  List<QualifiedObject<Domain>> getDomains();
  void addDomain(QualifiedObject<Domain> domain);
  void removeDomain(QualifiedObject<Domain> domain);
  int getRemainingDomainSelections();
  List<QualifiedObject<Domain>> getAvailableDomains();

  // -- Equipment --
  List<EquipmentFacade> getPurchasedEquipment();
  void addPurchasedEquipment(EquipmentFacade equipment, int quantity, {bool customize = false, bool free = false});
  void removePurchasedEquipment(EquipmentFacade equipment, int quantity, {bool free = false});
  bool isQualifiedForEquipment(EquipmentFacade equipment);

  // -- Funds --
  double getFunds();
  void setFunds(double newVal);
  void adjustFunds(double modVal);
  double getWealth();
  GearBuySellScheme? getGearBuySellScheme();
  void setGearBuySellScheme(GearBuySellScheme scheme);
  bool isAllowDebt();
  void setAllowDebt(bool allowed);
  bool isAutoResize();
  void setAutoResize(bool autoResize);

  // -- Languages --
  List<Language> getLanguages();
  bool isAutomatic(Language language);
  bool isRemovable(Language language);
  void removeLanguage(Language lang);

  // -- Templates --
  void addTemplate(PCTemplate template);
  void removeTemplate(PCTemplate template);
  List<PCTemplate> getTemplates();

  // -- XP --
  int getXP();
  void setXP(int xp);
  void adjustXP(int xp);
  int getXPForNextLevel();

  // -- DataSet --
  DataSetFacade getDataSet();

  // -- Underlying PC --
  PlayerCharacter getPC();

  // -- Dirty state --
  bool isDirty();
}
