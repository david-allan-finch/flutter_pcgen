import '../cdom/base/constants.dart';
import '../cdom/enumeration/integer_key.dart';
import 'ability.dart';
import 'ability_category.dart';
import 'campaign.dart';
import 'deity.dart';
import 'domain.dart';
import 'equipment.dart';
import 'language.dart';
import 'pc_alignment.dart';
import 'pc_class.dart';
import 'pc_template.dart';
import 'pc_stat.dart';
import 'race.dart';
import 'skill.dart';

// Tracks which class a character has and at what level.
class PCClassInfo {
  final PCClass pcClass;
  int level;
  PCClassInfo(this.pcClass, this.level);
}

// Basic character demographics
class CharacterDemographics {
  String name = '';
  String playerName = '';
  String bio = '';
  String description = '';
  String birthday = '';
  String birthplace = '';
  String residence = '';
  String region = '';
  String subregion = '';
  String gender = 'Neuter';
  String handed = '';
  String age = '';
  String height = '';
  String weight = '';
  String eyes = '';
  String hair = '';
  String skin = '';
  String interests = '';
  String speechPattern = '';
  String phobias = '';
  String catchPhrase = '';
  String trait1 = '';
  String trait2 = '';
  String portraitPath = '';
  String previewSheet = '';
}

// The central class representing a player character.
class PlayerCharacter {
  // Unique identifier
  final int _id;
  static int _nextId = 0;

  // Dirty tracking
  bool _dirtyFlag = false;

  // Demographics
  final CharacterDemographics demographics = CharacterDemographics();

  // Core attributes
  Race? _race;
  Deity? _deity;
  PCAlignment? _alignment;
  final Map<PCStat, int> _statValues = {};
  final Map<PCStat, bool> _nonAbilityStats = {};

  // Classes and levels
  final List<PCClassInfo> _classList = [];
  int _totalLevel = 0;

  // Templates
  final List<PCTemplate> _templateList = [];

  // Feats / Abilities
  final Map<AbilityCategory, List<Ability>> _abilities = {};

  // Skills
  final Map<Skill, double> _skillRanks = {};

  // Domains
  final List<Domain> _domains = [];

  // Languages
  final Set<Language> _languages = {};
  final Set<Language> _autoLanguages = {};

  // Equipment sets
  final List<Equipment> _equipmentList = [];
  final List<Equipment> _equippedEquipment = [];

  // Proficiencies
  final Set<String> _weaponProfList = {};
  final Set<String> _armorProfList = {};
  final Set<String> _shieldProfList = {};

  // XP and level tracking
  int _xp = 0;
  String _xpTableName = '';

  // HP
  final Map<int, int> _hitPointsPerLevel = {};
  int _manualHp = 0;

  // Wounds / status
  int _currentHp = 0;
  int _subDamage = 0;

  // Currency
  double _gold = 0.0;

  // Notes
  final List<String> _notes = [];

  // Spell books and known spells
  final Map<String, List<dynamic>> _spellBooks = {};
  final List<dynamic> _knownSpells = [];

  // Bonuses (cached)
  final Map<String, double> _bonusCache = {};

  // Followers / companions
  final List<dynamic> _followers = [];
  dynamic _master;

  // Campaigns loaded for this character
  final List<Campaign> _campaigns = {};

  // Variable store (for DEFINE: variables)
  final Map<String, num> _variables = {};

  // Misc flags
  bool _allowDebt = false;
  bool _ignoreCost = false;
  bool _useMonsterHD = false;
  bool _importing = false;
  bool _enabled = true;

  // Age set kit index
  int _ageSetKitSelections = 0;

  PlayerCharacter() : _id = _nextId++;

  int get id => _id;

  // --- Demographics ---
  String getName() => demographics.name;
  void setName(String name) { demographics.name = name; _setDirty(); }

  String getPlayersName() => demographics.playerName;
  void setPlayersName(String name) { demographics.playerName = name; _setDirty(); }

  // --- Dirty flag ---
  bool isDirty() => _dirtyFlag;
  void setDirty(bool dirty) { _dirtyFlag = dirty; }
  void _setDirty() { _dirtyFlag = true; }

  // --- Race ---
  Race? getRace() => _race;
  void setRace(Race? race) {
    _race = race;
    _setDirty();
  }

  // --- Deity ---
  Deity? getDeity() => _deity;
  void setDeity(Deity? deity) {
    _deity = deity;
    _setDirty();
  }

  // --- Alignment ---
  PCAlignment? getPCAlignment() => _alignment;
  void setPCAlignment(PCAlignment? alignment) {
    _alignment = alignment;
    _setDirty();
  }

  // --- Stats ---
  int getStatValue(PCStat stat) => _statValues[stat] ?? 10;

  void setStatValue(PCStat stat, int value) {
    _statValues[stat] = value;
    _setDirty();
  }

  int getStatModifier(PCStat stat) {
    final val = getStatValue(stat);
    return (val - 10) ~/ 2;
  }

  bool isNonAbility(PCStat stat) => _nonAbilityStats[stat] ?? false;
  void setNonAbility(PCStat stat, bool nonAbility) {
    _nonAbilityStats[stat] = nonAbility;
  }

  // --- Classes ---
  List<PCClassInfo> getClassList() => List.unmodifiable(_classList);

  void addClass(PCClass pcClass) {
    final existing = _classList.firstWhere(
      (info) => identical(info.pcClass, pcClass),
      orElse: () => PCClassInfo(pcClass, 0),
    );
    if (!_classList.contains(existing)) _classList.add(existing);
    existing.level++;
    _totalLevel++;
    _setDirty();
  }

  int getLevelForClass(PCClass pcClass) {
    for (final info in _classList) {
      if (identical(info.pcClass, pcClass)) return info.level;
    }
    return 0;
  }

  int getTotalLevels() => _totalLevel;

  int getCharacterLevel() => _totalLevel;

  // --- Templates ---
  List<PCTemplate> getTemplateList() => List.unmodifiable(_templateList);

  void addTemplate(PCTemplate template) {
    if (!_templateList.contains(template)) {
      _templateList.add(template);
      _setDirty();
    }
  }

  bool removeTemplate(PCTemplate template) {
    final removed = _templateList.remove(template);
    if (removed) _setDirty();
    return removed;
  }

  // --- Abilities ---
  List<Ability> getAbilityList(AbilityCategory category) {
    return List.unmodifiable(_abilities[category] ?? []);
  }

  void addAbility(AbilityCategory category, Ability ability) {
    _abilities.putIfAbsent(category, () => []).add(ability);
    _setDirty();
  }

  bool hasAbility(AbilityCategory category, Ability ability) {
    return _abilities[category]?.any(
      (a) => a.getKeyName().toLowerCase() == ability.getKeyName().toLowerCase()
    ) ?? false;
  }

  // --- Skills ---
  double getSkillRank(Skill skill) => _skillRanks[skill] ?? 0.0;

  void setSkillRank(Skill skill, double rank) {
    _skillRanks[skill] = rank;
    _setDirty();
  }

  Set<Skill> getSkillSet() => Set.unmodifiable(_skillRanks.keys);

  // --- Domains ---
  List<Domain> getDomainList() => List.unmodifiable(_domains);

  void addDomain(Domain domain) {
    if (!_domains.contains(domain)) {
      _domains.add(domain);
      _setDirty();
    }
  }

  bool hasDomain(Domain domain) => _domains.contains(domain);

  // --- Languages ---
  Set<Language> getLanguageSet() => Set.unmodifiable(_languages);

  void addLanguage(Language lang) {
    _languages.add(lang);
    _setDirty();
  }

  bool hasLanguage(Language lang) => _languages.contains(lang);

  // --- Equipment ---
  List<Equipment> getEquipmentList() => List.unmodifiable(_equipmentList);

  void addEquipment(Equipment eq) {
    _equipmentList.add(eq);
    _setDirty();
  }

  bool removeEquipment(Equipment eq) {
    final removed = _equipmentList.remove(eq);
    if (removed) _setDirty();
    return removed;
  }

  List<Equipment> getEquippedEquipment() => List.unmodifiable(_equippedEquipment);

  // --- Proficiencies ---
  bool hasWeaponProficient(String profName) => _weaponProfList.contains(profName);
  void addWeaponProf(String prof) { _weaponProfList.add(prof); }
  Set<String> getWeaponProfSet() => Set.unmodifiable(_weaponProfList);

  bool hasArmorProficient(String profName) => _armorProfList.contains(profName);
  void addArmorProf(String prof) { _armorProfList.add(prof); }

  bool hasShieldProficient(String profName) => _shieldProfList.contains(profName);
  void addShieldProf(String prof) { _shieldProfList.add(prof); }

  // --- XP ---
  int getXP() => _xp;
  void setXP(int xp) { _xp = xp; _setDirty(); }

  int getMinXPForNextECL() {
    // This would normally use XP tables; simplified
    return _xp;
  }

  // --- HP ---
  int getCurrentHP() => _currentHp;
  void setCurrentHP(int hp) { _currentHp = hp; _setDirty(); }

  int getHPAtLevel(int level) => _hitPointsPerLevel[level] ?? 0;
  void setHPAtLevel(int level, int hp) {
    _hitPointsPerLevel[level] = hp;
    _setDirty();
  }

  int getTotalHP() {
    return _hitPointsPerLevel.values.fold(0, (sum, hp) => sum + hp);
  }

  int getSubDamage() => _subDamage;
  void setSubDamage(int dmg) { _subDamage = dmg; _setDirty(); }

  // --- Gold ---
  double getGold() => _gold;
  void setGold(double gold) { _gold = gold; _setDirty(); }

  bool isAllowDebt() => _allowDebt;
  void setAllowDebt(bool allow) { _allowDebt = allow; }

  bool isIgnoreCost() => _ignoreCost;
  void setIgnoreCost(bool ignore) { _ignoreCost = ignore; }

  // --- Notes ---
  List<String> getNotesList() => List.unmodifiable(_notes);
  void addNote(String note) { _notes.add(note); _setDirty(); }

  // --- Variables ---
  num getVariable(String varName) => _variables[varName.toLowerCase()] ?? 0;
  void setVariable(String varName, num value) {
    _variables[varName.toLowerCase()] = value;
    _setDirty();
  }
  bool hasVariable(String varName) => _variables.containsKey(varName.toLowerCase());

  // --- Bonuses ---
  double getBonus(String bonusType, String bonusName) {
    return _bonusCache['$bonusType.$bonusName'] ?? 0.0;
  }

  void setBonusCache(String bonusType, String bonusName, double value) {
    _bonusCache['$bonusType.$bonusName'] = value;
  }

  // --- Followers ---
  List<dynamic> getFollowerList() => List.unmodifiable(_followers);
  void addFollower(dynamic follower) { _followers.add(follower); _setDirty(); }
  dynamic getMaster() => _master;
  void setMaster(dynamic master) { _master = master; _setDirty(); }

  // --- Campaigns ---
  Set<Campaign> getCampaignSet() => Set.unmodifiable(_campaigns);
  void addCampaign(Campaign campaign) { _campaigns.add(campaign); }

  // --- Misc ---
  bool isImporting() => _importing;
  void setImporting(bool importing) { _importing = importing; }

  bool isEnabled() => _enabled;

  // --- Qualifies check ---
  bool qualifies(dynamic reqObject) {
    // Deferred - full prereq evaluation
    return true;
  }

  @override
  String toString() => demographics.name.isEmpty ? 'Unnamed' : demographics.name;
}
