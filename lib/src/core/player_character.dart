//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.PlayerCharacter

import 'package:flutter_pcgen/src/cdom/base/constants.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/util/enumeration/attack_type.dart';
import 'package:flutter_pcgen/src/util/enumeration/load.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_alignment.dart';
import 'package:flutter_pcgen/src/core/pc_check.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/core/skill.dart';

// ---------------------------------------------------------------------------
// PCLevelInfo — data recorded per-level-up
// ---------------------------------------------------------------------------

/// Represents data kept about a single level a PC has taken.
final class PCLevelInfo {
  String _classKeyName;
  int classLevel;
  int skillPointsGained;
  int skillPointsRemaining;

  PCLevelInfo(this._classKeyName)
      : classLevel = 0,
        skillPointsGained = 0,
        skillPointsRemaining = 0;

  String get classKeyName => _classKeyName;
  set classKeyName(String value) => _classKeyName = value;
}

// ---------------------------------------------------------------------------
// PCClassInfo — class + level tracking within a character
// ---------------------------------------------------------------------------

/// Tracks which class a character has and at what level.
class PCClassInfo {
  final PCClass pcClass;
  int level;
  PCClassInfo(this.pcClass, this.level);
}

// ---------------------------------------------------------------------------
// CharacterDemographics — basic biography
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// SkillFilter enum (mirrors pcgen.cdom.enumeration.SkillFilter)
// ---------------------------------------------------------------------------

enum SkillFilter { all, usable, ranks, nonZero }

// ---------------------------------------------------------------------------
// SkillsOutputOrder enum (mirrors pcgen.cdom.enumeration.SkillsOutputOrder)
// ---------------------------------------------------------------------------

enum SkillsOutputOrder { nameAsc, nameDesc, trained, unTrained, rankAsc, rankDesc }

// ---------------------------------------------------------------------------
// PlayerCharacter
// ---------------------------------------------------------------------------

/// The central class representing a player character.
class PlayerCharacter {
  // Unique identifier
  final int _id;
  static int _nextId = 0;

  // Serial — incremented on every change, used by UI to detect staleness
  int _serial = 0;
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
  final List<PCLevelInfo> _levelInfo = [];

  // Templates
  final List<PCTemplate> _templateList = [];

  // Feats / Abilities
  final Map<AbilityCategory, List<Ability>> _abilities = {};

  // Skills
  final Map<Skill, double> _skillRanks = {};
  SkillFilter _skillFilter = SkillFilter.all;
  SkillsOutputOrder _skillsOutputOrder = SkillsOutputOrder.nameAsc;

  // Domains
  final List<Domain> _domains = [];
  int _maxDomains = 0;

  // Languages
  final Set<Language> _languages = {};
  final Set<Language> _autoLanguages = {};

  // Equipment
  final List<Equipment> _equipmentList = [];
  final List<Equipment> _equippedEquipment = [];
  final List<Equipment> _tempBonusItemList = [];
  String _calcEquipSetId = 'O.1';

  // Proficiencies
  final Set<String> _weaponProfList = {};
  final Set<String> _armorProfList = {};
  final Set<String> _shieldProfList = {};

  // XP and level tracking
  int _xp = 0;
  String _xpTableName = '';

  // HP per class level (key = overall level index)
  final Map<int, int> _hitPointsPerLevel = {};

  // Wounds / status
  int _currentHp = 0;
  int _subDamage = 0;

  // Currency
  double _gold = 0.0;
  int _costPool = 0;

  // Notes
  final List<dynamic> _notes = [];

  // Spell books: name → SpellBook
  final Map<String, dynamic> _spellBooks = {};
  String _spellBookNameToAutoAddKnown = '';
  int _spellLevelTemp = 0;
  bool _autoKnownSpells = true;
  bool _useHigherKnownSlots = true;
  bool _useHigherPreppedSlots = true;

  // Bonuses (cached)
  final Map<String, double> _bonusCache = {};
  final Map<String, double> _tempBonusFilters = {};
  bool _useTempMods = true;

  // Followers / companions
  final List<dynamic> _followers = [];
  dynamic _master;
  bool _autoLoadCompanion = false;

  // Campaigns loaded for this character
  final List<Campaign> _campaigns = [];

  // Variable store (DEFINE: variables)
  final Map<String, num> _variables = {};

  // Pool / point buy
  int _poolAmount = 0;
  int _pointBuyPoints = -1;
  int _currentEquipSetNumber = 0;

  // Misc flags
  bool _allowDebt = false;
  bool _ignoreCost = false;
  bool _autoResize = true;
  bool _importing = false;
  bool _enabled = true;
  bool _processLevelAbilities = true;
  bool _allowInteraction = true;

  // Output sheets
  String _outputSheetHTML = '';
  String _outputSheetPDF = '';

  // File tracking
  String _fileName = '';

  // Age set kit selections (up to Constants.NUMBER_OF_AGESET_KIT_SELECTIONS)
  final List<bool> _ageSetKitSelections = List.filled(10, false);

  PlayerCharacter() : _id = _nextId++;

  int get id => _id;

  // ---------------------------------------------------------------------------
  // Dirty / serial
  // ---------------------------------------------------------------------------

  bool isDirty() => _dirtyFlag;
  void setDirty(bool dirty) {
    _dirtyFlag = dirty;
    if (dirty) _serial++;
  }

  void _setDirty() => setDirty(true);
  int getSerial() => _serial;

  // ---------------------------------------------------------------------------
  // Demographics
  // ---------------------------------------------------------------------------

  String getName() => demographics.name;
  void setName(String name) {
    demographics.name = name;
    _setDirty();
  }

  String getPlayersName() => demographics.playerName;
  void setPlayersName(String name) {
    demographics.playerName = name;
    _setDirty();
  }

  String getGender() => demographics.gender;
  void setGender(String g) {
    demographics.gender = g;
    _setDirty();
  }

  String getEyeColor() => demographics.eyes;
  void setEyeColor(String s) {
    demographics.eyes = s;
    _setDirty();
  }

  String getHairColor() => demographics.hair;
  void setHairColor(String s) {
    demographics.hair = s;
    _setDirty();
  }

  String getSkinColor() => demographics.skin;
  void setSkinColor(String s) {
    demographics.skin = s;
    _setDirty();
  }

  String getHeight() => demographics.height;
  void setHeight(String h) {
    demographics.height = h;
    _setDirty();
  }

  String getWeight() => demographics.weight;
  void setWeight(String w) {
    demographics.weight = w;
    _setDirty();
  }

  String getAge() => demographics.age;
  void setAge(String a) {
    demographics.age = a;
    _setDirty();
  }

  String getBio() => demographics.bio;
  void setBio(String bio) {
    demographics.bio = bio;
    _setDirty();
  }

  String getDescription() => demographics.description;
  void setDescription(String d) {
    demographics.description = d;
    _setDirty();
  }

  String getRegion() => demographics.region;
  void setRegion(String r) {
    demographics.region = r;
    _setDirty();
  }

  String getBirthday() => demographics.birthday;
  void setBirthday(String b) {
    demographics.birthday = b;
    _setDirty();
  }

  String getBirthplace() => demographics.birthplace;
  void setBirthplace(String b) {
    demographics.birthplace = b;
    _setDirty();
  }

  String getResidence() => demographics.residence;
  void setResidence(String r) {
    demographics.residence = r;
    _setDirty();
  }

  String getPortraitPath() => demographics.portraitPath;
  void setPortraitPath(String p) {
    demographics.portraitPath = p;
    _setDirty();
  }

  String getPreviewSheet() => demographics.previewSheet;
  void setPreviewSheet(String s) {
    demographics.previewSheet = s;
    _setDirty();
  }

  String getInterests() => demographics.interests;
  void setInterests(String s) {
    demographics.interests = s;
    _setDirty();
  }

  String getSpeechPattern() => demographics.speechPattern;
  void setSpeechPattern(String s) {
    demographics.speechPattern = s;
    _setDirty();
  }

  String getPhobias() => demographics.phobias;
  void setPhobias(String s) {
    demographics.phobias = s;
    _setDirty();
  }

  String getCatchPhrase() => demographics.catchPhrase;
  void setCatchPhrase(String s) {
    demographics.catchPhrase = s;
    _setDirty();
  }

  String getTrait1() => demographics.trait1;
  void setTrait1(String s) {
    demographics.trait1 = s;
    _setDirty();
  }

  String getTrait2() => demographics.trait2;
  void setTrait2(String s) {
    demographics.trait2 = s;
    _setDirty();
  }

  /// Set a PCString attribute by key name.
  void setPCAttribute(String attrKey, String value) {
    switch (attrKey.toUpperCase()) {
      case 'NAME':       demographics.name = value;
      case 'PLAYERSNAME': demographics.playerName = value;
      case 'BIO':        demographics.bio = value;
      case 'DESCRIPTION': demographics.description = value;
      case 'BIRTHDAY':   demographics.birthday = value;
      case 'BIRTHPLACE': demographics.birthplace = value;
      case 'RESIDENCE':  demographics.residence = value;
      case 'REGION':     demographics.region = value;
      case 'GENDER':     demographics.gender = value;
      case 'HANDED':     demographics.handed = value;
      case 'AGE':        demographics.age = value;
      case 'HEIGHT':     demographics.height = value;
      case 'WEIGHT':     demographics.weight = value;
      case 'EYES':       demographics.eyes = value;
      case 'HAIR':       demographics.hair = value;
      case 'SKIN':       demographics.skin = value;
      case 'INTERESTS':  demographics.interests = value;
      case 'SPEECHPATTERN': demographics.speechPattern = value;
      case 'PHOBIAS':    demographics.phobias = value;
      case 'CATCHPHRASE': demographics.catchPhrase = value;
      case 'TRAIT1':     demographics.trait1 = value;
      case 'TRAIT2':     demographics.trait2 = value;
      case 'PORTRAIT':   demographics.portraitPath = value;
      case 'PREVIEWSHEET': demographics.previewSheet = value;
    }
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // File
  // ---------------------------------------------------------------------------

  String getFileName() => _fileName;
  void setFileName(String name) => _fileName = name;

  // ---------------------------------------------------------------------------
  // Output sheets
  // ---------------------------------------------------------------------------

  String getSelectedCharacterHTMLOutputSheet() => _outputSheetHTML;
  void setSelectedCharacterHTMLOutputSheet(String s) => _outputSheetHTML = s;

  String getSelectedCharacterPDFOutputSheet() => _outputSheetPDF;
  void setSelectedCharacterPDFOutputSheet(String s) => _outputSheetPDF = s;

  // ---------------------------------------------------------------------------
  // Race
  // ---------------------------------------------------------------------------

  Race? getRace() => _race;

  bool setRace(Race? newRace) {
    if (identical(_race, newRace)) return false;
    _race = newRace;
    _setDirty();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Deity
  // ---------------------------------------------------------------------------

  Deity? getDeity() => _deity;
  void setDeity(Deity? deity) {
    _deity = deity;
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // Alignment
  // ---------------------------------------------------------------------------

  PCAlignment? getPCAlignment() => _alignment;
  void setPCAlignment(PCAlignment? alignment) {
    _alignment = alignment;
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  int getStatValue(PCStat stat) => _statValues[stat] ?? 10;

  void setStatValue(PCStat stat, int value) {
    _statValues[stat] = value;
    _setDirty();
  }

  int getStatModifier(PCStat stat) => (getStatValue(stat) - 10) ~/ 2;

  bool isNonAbility(PCStat stat) => _nonAbilityStats[stat] ?? false;

  void setNonAbility(PCStat stat, bool nonAbility) {
    _nonAbilityStats[stat] = nonAbility;
  }

  /// Returns the total stat value for [stat] at character level [level],
  /// including/excluding post-level bonuses depending on [includePost].
  int getTotalStatAtLevel(PCStat stat, int level, bool includePost) {
    // TODO: implement full stat-at-level calculation
    return getStatValue(stat);
  }

  // ---------------------------------------------------------------------------
  // Classes and level info
  // ---------------------------------------------------------------------------

  List<PCClassInfo> getClassList() => List.unmodifiable(_classList);
  Set<PCClass> getClassSet() => {for (final i in _classList) i.pcClass};

  PCClass? getClassKeyed(String key) {
    for (final info in _classList) {
      if (info.pcClass.getKeyName() == key) return info.pcClass;
    }
    return null;
  }

  void addClass(PCClass pcClass) {
    PCClassInfo? existing;
    for (final info in _classList) {
      if (identical(info.pcClass, pcClass)) {
        existing = info;
        break;
      }
    }
    if (existing == null) {
      existing = PCClassInfo(pcClass, 0);
      _classList.add(existing);
    }
    existing.level++;
    _totalLevel++;
    _levelInfo.add(PCLevelInfo(pcClass.getKeyName())
      ..classLevel = existing.level);
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

  // --- PCLevelInfo ---

  List<PCLevelInfo> getLevelInfo() => List.unmodifiable(_levelInfo);
  int getLevelInfoSize() => _levelInfo.length;

  PCLevelInfo? getLevelInfoAt(int index) {
    if (index < 0 || index >= _levelInfo.length) return null;
    return _levelInfo[index];
  }

  String getLevelInfoClassKeyName(int idx) =>
      (idx >= 0 && idx < _levelInfo.length)
          ? _levelInfo[idx].classKeyName
          : '';

  PCLevelInfo? getLevelInfoFor(String classKey, int level) {
    for (final li in _levelInfo) {
      if (li.classKeyName == classKey && li.classLevel == level) return li;
    }
    return null;
  }

  List<PCLevelInfo> clearLevelInfo() {
    final old = List<PCLevelInfo>.from(_levelInfo);
    _levelInfo.clear();
    return old;
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  List<PCTemplate> getTemplateList() => List.unmodifiable(_templateList);
  Set<PCTemplate> getTemplateSet() => Set.unmodifiable(_templateList.toSet());

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

  // ---------------------------------------------------------------------------
  // Abilities / Feats
  // ---------------------------------------------------------------------------

  List<Ability> getAbilityList(AbilityCategory category) =>
      List.unmodifiable(_abilities[category] ?? []);

  void addAbility(AbilityCategory category, Ability ability) {
    _abilities.putIfAbsent(category, () => []).add(ability);
    _setDirty();
  }

  bool hasAbility(AbilityCategory category, Ability ability) {
    return _abilities[category]?.any((a) =>
            a.getKeyName().toLowerCase() == ability.getKeyName().toLowerCase()) ??
        false;
  }

  Ability? getMatchingAbility(AbilityCategory category, Ability ability) {
    for (final a in (_abilities[category] ?? [])) {
      if (a.getKeyName().toLowerCase() == ability.getKeyName().toLowerCase()) {
        return a;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Skills
  // ---------------------------------------------------------------------------

  double getSkillRank(Skill skill) => _skillRanks[skill] ?? 0.0;

  void setSkillRank(Skill skill, double rank) {
    _skillRanks[skill] = rank;
    _setDirty();
  }

  Set<Skill> getSkillSet() => Set.unmodifiable(_skillRanks.keys);

  int getSkillPoints() {
    // TODO: compute from INT modifier + class bonuses
    return 0;
  }

  double? getMaxRank(Skill skill, PCClass? pcClass) {
    // TODO: compute based on cross-class / class skill status
    return (_totalLevel + 3.0);
  }

  SkillFilter getSkillFilter() => _skillFilter;
  void setSkillFilter(SkillFilter filter) {
    _skillFilter = filter;
    _setDirty();
  }

  SkillsOutputOrder getSkillsOutputOrder() => _skillsOutputOrder;
  void setSkillsOutputOrder(SkillsOutputOrder order) {
    _skillsOutputOrder = order;
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // Domains
  // ---------------------------------------------------------------------------

  List<Domain> getDomainList() => List.unmodifiable(_domains);

  void addDomain(Domain domain) {
    if (!_domains.contains(domain)) {
      _domains.add(domain);
      _setDirty();
    }
  }

  bool hasDomain(Domain domain) => _domains.contains(domain);

  int getMaxCharacterDomains() => _maxDomains;
  void setMaxCharacterDomains(int max) { _maxDomains = max; }

  // ---------------------------------------------------------------------------
  // Languages
  // ---------------------------------------------------------------------------

  Set<Language> getLanguageSet() => Set.unmodifiable(_languages);

  void addLanguage(Language lang) {
    _languages.add(lang);
    _setDirty();
  }

  bool hasLanguage(Language lang) => _languages.contains(lang);

  // ---------------------------------------------------------------------------
  // Equipment
  // ---------------------------------------------------------------------------

  List<Equipment> getEquipmentMasterList() => List.unmodifiable(_equipmentList);
  List<Equipment> getEquipmentList() => List.unmodifiable(_equipmentList);
  List<Equipment> getEquipmentListInOutputOrder([int merge = 3]) =>
      List.unmodifiable(_equipmentList);

  void addEquipment(Equipment eq) {
    _equipmentList.add(eq);
    _setDirty();
  }

  void removeEquipment(Equipment eq) {
    _equipmentList.remove(eq);
    _setDirty();
  }

  List<Equipment> getEquippedEquipment() => List.unmodifiable(_equippedEquipment);
  Set<Equipment> getEquippedEquipmentSet() => Set.unmodifiable(_equippedEquipment.toSet());

  Equipment? getEquipmentNamed(String name) {
    for (final eq in _equipmentList) {
      if (eq.getName() == name) return eq;
    }
    return null;
  }

  List<Equipment> getEquipmentOfType(String typeName, int status) {
    return _equipmentList.where((eq) => eq.isType(typeName)).toList();
  }

  List<Equipment> getEquipmentOfTypeInOutputOrder(String typeName, int status) =>
      getEquipmentOfType(typeName, status);

  List<Equipment> getExpandedWeapons(int merge) {
    // TODO: expand stacked weapons
    return getEquipmentOfType('WEAPON', 1);
  }

  String getCalcEquipSetId() => _calcEquipSetId;
  void setCalcEquipSetId(String id) { _calcEquipSetId = id; }

  int getEquipSetNumber() => _currentEquipSetNumber;

  // ---------------------------------------------------------------------------
  // Proficiencies
  // ---------------------------------------------------------------------------

  bool hasWeaponProf(dynamic wp) =>
      _weaponProfList.contains(wp?.getKeyName() ?? wp.toString());
  bool hasWeaponProficient(String profName) => _weaponProfList.contains(profName);
  void addWeaponProf(String prof) { _weaponProfList.add(prof); }
  Set<String> getWeaponProfSet() => Set.unmodifiable(_weaponProfList);

  bool hasArmorProficient(String profName) => _armorProfList.contains(profName);
  void addArmorProf(String prof) { _armorProfList.add(prof); }

  bool hasShieldProficient(String profName) => _shieldProfList.contains(profName);
  void addShieldProf(String prof) { _shieldProfList.add(prof); }

  bool isProficientWith(Equipment eq) {
    // TODO: full proficiency check via prof providers
    return false;
  }

  // ---------------------------------------------------------------------------
  // XP
  // ---------------------------------------------------------------------------

  int getXP() => _xp;
  void setXP(int xp) {
    _xp = xp;
    _setDirty();
  }

  String getXPTableName() => _xpTableName;
  void setXPTable(String xpTableName) {
    _xpTableName = xpTableName;
    _setDirty();
  }

  dynamic getXPTableLevelInfo(int level) {
    // TODO: look up from XPTable
    return null;
  }

  // ---------------------------------------------------------------------------
  // HP
  // ---------------------------------------------------------------------------

  int getCurrentHP() => _currentHp;
  void setCurrentHP(int hp) {
    _currentHp = hp;
    _setDirty();
  }

  int getHPAtLevel(int level) => _hitPointsPerLevel[level] ?? 0;
  void setHPAtLevel(int level, int hp) {
    _hitPointsPerLevel[level] = hp;
    _setDirty();
  }

  int getTotalHP() =>
      _hitPointsPerLevel.values.fold(0, (sum, hp) => sum + hp);

  int getSubDamage() => _subDamage;
  void setSubDamage(int dmg) {
    _subDamage = dmg;
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  double getGold() => _gold;
  void setGold(double gold) {
    _gold = gold;
    _setDirty();
  }

  int getCostPool() => _costPool;
  void setCostPool(int i) { _costPool = i; }

  bool isAllowDebt() => _allowDebt;
  void setAllowDebt(bool allow) { _allowDebt = allow; }

  bool isIgnoreCost() => _ignoreCost;
  void setIgnoreCost(bool ignore) { _ignoreCost = ignore; }

  // ---------------------------------------------------------------------------
  // Notes
  // ---------------------------------------------------------------------------

  List<dynamic> getNotesList() => List.unmodifiable(_notes);
  void addNotesItem(dynamic item) {
    _notes.add(item);
    _setDirty();
  }

  // ---------------------------------------------------------------------------
  // Variables
  // ---------------------------------------------------------------------------

  /// Returns the value of a character variable (DEFINE: variables).
  num getVariable(String varName, {bool isMax = false}) =>
      _variables[varName.toLowerCase()] ?? 0;

  /// Returns the evaluated value of a formula string.
  num getVariableValue(String formula, String src) {
    // TODO: evaluate via formula system
    // Try direct variable lookup first
    return _variables[formula.toLowerCase()] ?? 0;
  }

  void setVariable(String varName, num value) {
    _variables[varName.toLowerCase()] = value;
    _setDirty();
  }

  bool hasVariable(String varName) =>
      _variables.containsKey(varName.toLowerCase());

  // ---------------------------------------------------------------------------
  // Bonuses
  // ---------------------------------------------------------------------------

  /// Returns the total bonus to [bonusType].[bonusName].
  double getTotalBonusTo(String bonusType, String bonusName) {
    return _bonusCache['$bonusType.$bonusName'] ?? 0.0;
  }

  /// Sets a cached bonus value (used during bonus recalculation).
  void setBonusCache(String bonusType, String bonusName, double value) {
    _bonusCache['$bonusType.$bonusName'] = value;
  }

  /// Returns bonus from a specific bonus type breakdown.
  double getBonus(String bonusType, String bonusName) =>
      getTotalBonusTo(bonusType, bonusName);

  /// Returns only the bonus contributed by feats/abilities.
  double getFeatBonusTo(String aType, String aName) =>
      getTotalBonusTo(aType, aName); // TODO: filter to feat sources only

  /// Returns only the bonus contributed by the character's race.
  double getRaceBonusTo(String aType, String aName) => 0.0; // TODO

  /// Returns only the bonus contributed by templates.
  double getTemplateBonusTo(String aType, String aName) => 0.0; // TODO

  /// Returns only the bonus from size adjustments.
  double getSizeAdjustmentBonusTo(String aType, String aName) => 0.0; // TODO

  /// Returns the bonus due to a specific bonus type (e.g. Armor, Natural).
  double getBonusDueToType(String mainType, String subType, String bonusType) =>
      0.0; // TODO: filter bonus list by type

  double calcBonusFromList(List<dynamic> bonusList, dynamic source) {
    // TODO: sum bonus values from list
    return 0.0;
  }

  // ---------------------------------------------------------------------------
  // Saving throws / Checks
  // ---------------------------------------------------------------------------

  /// Returns the base save value for [check] (from class progressions).
  int getBaseCheck(PCCheck check) {
    return getTotalBonusTo('SAVE', 'BASE.${check.getKeyName()}').toInt();
  }

  /// Returns the total save value for [check] including all bonuses.
  int getTotalCheck(PCCheck check) {
    return getBaseCheck(check) +
        getTotalBonusTo('SAVE', check.getKeyName()).toInt();
  }

  // ---------------------------------------------------------------------------
  // Attack
  // ---------------------------------------------------------------------------

  /// Returns the character's base attack bonus.
  int baseAttackBonus() => getTotalBonusTo('COMBAT', 'BAB').toInt();

  /// Returns the attack string (e.g. "+8/+3") for the given attack type.
  String getAttackString(AttackType at, {int toHitBonus = 0, int babBonus = 0}) {
    // TODO: implement full multi-attack string calculation
    final bab = baseAttackBonus() + babBonus + toHitBonus;
    if (bab <= 0) return bab.toString();
    final attacks = <String>[];
    int current = bab;
    while (current > 0) {
      attacks.add(current >= 0 ? '+$current' : '$current');
      current -= 5;
    }
    return attacks.join('/');
  }

  /// Returns the off-hand light weapon bonus.
  int getOffHandLightBonus() => 0; // TODO

  // ---------------------------------------------------------------------------
  // Spell resistance
  // ---------------------------------------------------------------------------

  int getSR() => getTotalBonusTo('MISC', 'SR').toInt();

  // ---------------------------------------------------------------------------
  // Spell casting
  // ---------------------------------------------------------------------------

  /// Returns true if the character is a spell caster of at least [minLevel].
  bool isSpellCaster(int minLevel) {
    for (final info in _classList) {
      if (info.level >= minLevel) {
        // TODO: check if this class is a spell caster
        return true;
      }
    }
    return false;
  }

  /// Returns the total caster level for [aClass].
  int getCasterLevelForClass(PCClass aClass) {
    // TODO: look up via class facet and bonuses
    return getLevelForClass(aClass);
  }

  /// Returns the caster level for a specific character spell.
  int getCasterLevelForSpell(dynamic aSpell) {
    // TODO: derive from spell's class source
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Spell books
  // ---------------------------------------------------------------------------

  dynamic getSpellBookByName(String name) => _spellBooks[name];

  String getSpellBookNameToAutoAddKnown() => _spellBookNameToAutoAddKnown;
  void setSpellBookNameToAutoAddKnown(String s) {
    _spellBookNameToAutoAddKnown = s;
    _setDirty();
  }

  int getSpellLevelTemp() => _spellLevelTemp;

  bool getAutoSpells() => _autoKnownSpells;
  void setAutoSpells(bool b) { _autoKnownSpells = b; }

  bool getUseHigherKnownSlots() => _useHigherKnownSlots;
  void setUseHigherKnownSlots(bool b) { _useHigherKnownSlots = b; }

  bool getUseHigherPreppedSlots() => _useHigherPreppedSlots;
  void setUseHigherPreppedSlots(bool b) { _useHigherPreppedSlots = b; }

  /// Returns the first class that can cast spells, by index.
  dynamic getSpellClassAtIndex(int ix) {
    // TODO: filter class list to spell-caster classes
    return ix < _classList.length ? _classList[ix].pcClass : null;
  }

  String getSpellRange(dynamic aSpell, dynamic si) {
    // TODO: compute spell range string
    return '';
  }

  // ---------------------------------------------------------------------------
  // Temp bonuses
  // ---------------------------------------------------------------------------

  Map<dynamic, dynamic> getTempBonusMap() => {}; // TODO
  Set<String> getTempBonusFilters() => _tempBonusFilters.keys.toSet();
  void setTempBonusFilter(String aBonusStr) { _tempBonusFilters[aBonusStr] = 1; }
  void unsetTempBonusFilter(String aBonusStr) { _tempBonusFilters.remove(aBonusStr); }

  List<String> getNamedTempBonusList() => []; // TODO
  List<String> getNamedTempBonusDescList() => []; // TODO

  dynamic addTempBonus(dynamic aBonus, Object source, Object target) {
    // TODO: apply temp bonus
    return null;
  }

  void addTempBonusItemList(Equipment eq) {
    _tempBonusItemList.add(eq);
    _setDirty();
  }

  bool getUseTempMods() => _useTempMods;
  void setUseTempMods(bool b) { _useTempMods = b; }

  // ---------------------------------------------------------------------------
  // Pool / Point Buy
  // ---------------------------------------------------------------------------

  int getPoolAmount() => _poolAmount;
  void setPoolAmount(int pool) { _poolAmount = pool; }

  int getPointBuyPoints() => _pointBuyPoints;
  void setPointBuyPoints(int pts) { _pointBuyPoints = pts; }

  // ---------------------------------------------------------------------------
  // Followers / companions
  // ---------------------------------------------------------------------------

  List<dynamic> getFollowerList() => List.unmodifiable(_followers);

  void addFollower(dynamic follower) {
    _followers.add(follower);
    _setDirty();
  }

  void delFollower(dynamic follower) {
    _followers.remove(follower);
    _setDirty();
  }

  dynamic getMaster() => _master;
  void setMaster(dynamic master) {
    _master = master;
    _setDirty();
  }

  PlayerCharacter? getMasterPC() {
    // TODO: look up master's PlayerCharacter from CharacterManager
    return null;
  }

  int getEffectiveCompanionLevel(dynamic compList) => 0; // TODO
  int getMaxFollowers(dynamic compList) => 0; // TODO

  bool getLoadCompanion() => _autoLoadCompanion;
  void setLoadCompanion(bool b) { _autoLoadCompanion = b; }

  // ---------------------------------------------------------------------------
  // Campaigns
  // ---------------------------------------------------------------------------

  List<Campaign> getCampaignSet() => List.unmodifiable(_campaigns);
  void addCampaign(Campaign campaign) { _campaigns.add(campaign); }

  // ---------------------------------------------------------------------------
  // Kits
  // ---------------------------------------------------------------------------

  List<dynamic> getKitInfo() => []; // TODO: return kit list

  bool isHasMadeKitSelectionForAgeSet(int index) =>
      index < _ageSetKitSelections.length && _ageSetKitSelections[index];

  void setHasMadeKitSelectionForAgeSet(int index, bool arg) {
    if (index < _ageSetKitSelections.length) _ageSetKitSelections[index] = arg;
  }

  // ---------------------------------------------------------------------------
  // Special abilities
  // ---------------------------------------------------------------------------

  List<dynamic> getSpecialAbilityList() => []; // TODO
  List<String> getSpecialAbilityTimesList() => []; // TODO

  // ---------------------------------------------------------------------------
  // Qualifies
  // ---------------------------------------------------------------------------

  bool qualifies(dynamic reqObject) {
    // TODO: full prereq evaluation via QualifyFacet
    return true;
  }

  bool checkQualifyList(dynamic obj) => qualifies(obj);

  // ---------------------------------------------------------------------------
  // Auto-resize
  // ---------------------------------------------------------------------------

  bool isAutoResize() => _autoResize;
  void setAutoResize(bool b) { _autoResize = b; }

  // ---------------------------------------------------------------------------
  // Importing flag
  // ---------------------------------------------------------------------------

  bool isImporting() => _importing;
  void setImporting(bool importing) { _importing = importing; }

  bool isEnabled() => _enabled;

  bool isProcessLevelAbilities() => _processLevelAbilities;
  void setProcessLevelAbilities(bool b) { _processLevelAbilities = b; }

  bool isAllowInteraction() => _allowInteraction;
  void setAllowInteraction(bool b) { _allowInteraction = b; }

  // ---------------------------------------------------------------------------
  // Load / encumbrance
  // ---------------------------------------------------------------------------

  Load getLoadType() => Load.light; // TODO: compute from encumbrance

  // ---------------------------------------------------------------------------
  // toString
  // ---------------------------------------------------------------------------

  @override
  String toString() =>
      demographics.name.isEmpty ? 'Unnamed' : demographics.name;
}
