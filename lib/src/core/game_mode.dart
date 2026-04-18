// Translation of pcgen.core.GameMode

import '../cdom/base/constants.dart';
import '../cdom/enumeration/type.dart';
import '../rules/context/load_context.dart';

// ---------------------------------------------------------------------------
// XPTable — experience point table
// ---------------------------------------------------------------------------

class XPTable {
  final String name;
  final Map<int, int> levelXP;

  const XPTable(this.name, this.levelXP);

  int getXPForLevel(int level) => levelXP[level] ?? 0;
}

// ---------------------------------------------------------------------------
// LevelInfo — one row in an XP table
// ---------------------------------------------------------------------------

class LevelInfo {
  final int level;
  final int xpRequired;

  const LevelInfo(this.level, this.xpRequired);
}

// ---------------------------------------------------------------------------
// ClassType — maps class type name to properties
// ---------------------------------------------------------------------------

class ClassType {
  String name;
  bool isMonster;

  ClassType(this.name, {this.isMonster = false});

  String getName() => name;
}

// ---------------------------------------------------------------------------
// PointBuyCost — one entry in a point-buy table
// ---------------------------------------------------------------------------

class PointBuyCost {
  final int stat;
  final int cost;

  const PointBuyCost(this.stat, this.cost);
}

// ---------------------------------------------------------------------------
// GameMode
// ---------------------------------------------------------------------------

/// Handles game mode configuration (D&D 3.5, Pathfinder, 5e, etc).
final class GameMode implements Comparable<Object> {
  String _name = '';
  String _displayName = '';
  String _folderName = '';

  // Context for loading game-mode-specific LST data
  late final LoadContext _modeContext = LoadContext();

  // Allowed modes and collections
  List<String> allowedModes = [];
  List<String> bonusFeatLevels = [];
  List<String> bonusStackList = [];
  List<String> bonusStatLevels = [];
  List<String> defaultDataSetList = [];
  Map<String, XPTable> xpTableInfo = {};
  List<String> skillMultiplierLevels = [];
  Map<Type, String> plusCalcs = {};
  Map<String, String> spellRangeMap = {};
  List<Type> weaponCategories = [];
  final Map<Type, String> _weaponTypeAbbrev = {};
  final Map<int, int> _xpAwards = {};
  final Map<int, String> _crSteps = {};
  final List<dynamic> _wieldCategories = [];
  final List<PointBuyCost> _pointBuyStatCosts = [];
  final List<ClassType> _classTypes = [];
  List<int>? _dieSizes;

  // Text / display properties
  String _althpAbbrev = '';
  String _althpName = '';
  String _acText = '';
  String _currencyUnit = 'gp';
  String _currencyUnitAbbrev = 'gp';
  String _damageResistanceText = '';
  String _defaultSpellbook = '';
  String _defaultUnitSet = Constants.standardUnitsetName;
  String _displayVariableText = '';
  bool _displayVariableName = false;
  bool _displayVariableValue = false;
  int _defaultMaxLevel = 20;
  bool _skillPointsPerLevelModified = true;
  int _maxNonEpicLevel = 20;
  String _levelUpMessage = '';
  String _hpAbbrev = 'HP';
  String _hpName = 'Hit Points';
  int _rollMethod = Constants.hpStandard;
  int _rollHP = 0;
  int _purchaseModeMethodNum = 0;
  String _qualifier = '';
  String _spellBaseConcentration = '';
  String _spellBaseDC = '';
  String _spellRangeExpression = '';
  int _statMax = 18;
  int _statMin = 3;
  String _tabName = '';
  String _unitSetName = '';
  String _varPrefix = '';
  String _menuEntry = '';
  bool _allowFreeBooks = false;
  bool _multiHanded = false;
  String _spellListFmt = '';
  String _acformula = '';
  int _babMaxAtt = 4;
  int _babMinVal = 0;
  int _babAttCyc = 5;
  String _rollFormula = '';
  String _moveFormula = '';
  bool _xpEnabled = true;
  String _deityTerm = 'Deity';
  List<String> _gameModeDisplayNames = [];
  String _crThreshold = '';
  String _weaponReachFormula = '';
  int _shortRangeDistance = 30;
  String _rankModFormula = '';
  dynamic _featTemplate;

  GameMode(String name) : _name = name, _folderName = name;

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  String getName() => _name;
  void setName(String name) { _name = name; }

  String getDisplayName() => _displayName.isEmpty ? _name : _displayName;
  void setDisplayName(String name) { _displayName = name; }

  String getFolderName() => _folderName.isEmpty ? _name : _folderName;

  LoadContext getModeContext() => _modeContext;

  // ---------------------------------------------------------------------------
  // Die sizes
  // ---------------------------------------------------------------------------

  List<int>? getDieSizes() => _dieSizes == null ? null : List.unmodifiable(_dieSizes!);
  void setDieSizes(List<int> sizes) { _dieSizes = sizes; }

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  String getCurrencyUnit() => _currencyUnit;
  void setCurrencyUnit(String unit) { _currencyUnit = unit; }
  String getCurrencyUnitAbbrev() => _currencyUnitAbbrev;
  void setCurrencyUnitAbbrev(String abbrev) { _currencyUnitAbbrev = abbrev; }

  // ---------------------------------------------------------------------------
  // Spells
  // ---------------------------------------------------------------------------

  String getDefaultSpellbook() => _defaultSpellbook;
  void setDefaultSpellBook(String book) { _defaultSpellbook = book; }

  String getSpellBaseDC() => _spellBaseDC;
  void setSpellBaseDC(String formula) { _spellBaseDC = formula; }

  String getSpellBaseConcentration() => _spellBaseConcentration;
  void setSpellBaseConcentration(String formula) { _spellBaseConcentration = formula; }

  void addSpellRange(String aRange, String aFormula) {
    spellRangeMap[aRange] = aFormula;
  }

  // ---------------------------------------------------------------------------
  // HP / levels
  // ---------------------------------------------------------------------------

  int getDefaultMaxLevel() => _defaultMaxLevel;
  void setDefaultMaxLevel(int level) { _defaultMaxLevel = level; }

  int getMaxNonEpicLevel() => _maxNonEpicLevel;
  void setMaxNonEpicLevel(int level) { _maxNonEpicLevel = level; }

  String getHPAbbrev() => _hpAbbrev;
  void setHPAbbrev(String abbrev) { _hpAbbrev = abbrev; }
  String getHPName() => _hpName;
  void setHPName(String name) { _hpName = name; }

  int getRollMethod() => _rollMethod;
  void setRollMethod(int method) { _rollMethod = method; }

  String getLevelUpMessage() => _levelUpMessage;
  void setLevelUpMessage(String msg) { _levelUpMessage = msg; }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  int getStatMax() => _statMax;
  void setStatMax(int max) { _statMax = max; }
  int getStatMin() => _statMin;
  void setStatMin(int min) { _statMin = min; }

  // ---------------------------------------------------------------------------
  // BAB / attack
  // ---------------------------------------------------------------------------

  int getBabAttCyc() => _babAttCyc;
  void setBabAttCyc(int attCyc) { _babAttCyc = attCyc; }

  int getBabMaxAtt() => _babMaxAtt;
  void setBabMaxAtt(int maxAtt) { _babMaxAtt = maxAtt; }

  int getBabMinVal() => _babMinVal;
  void setBabMinVal(int minVal) { _babMinVal = minVal; }

  // ---------------------------------------------------------------------------
  // AC
  // ---------------------------------------------------------------------------

  String getACText() => _acText;
  void setACText(String s) { _acText = s; }
  String getACFormula() => _acformula;
  void setACFormula(String formula) { _acformula = formula; }

  bool isValidACType(String acType) => true; // TODO: check AC type registry
  void addACAdds(String acType, List<dynamic> controls) {} // TODO
  void addACRemoves(String acType, List<dynamic> controls) {} // TODO
  List<dynamic> getACTypeAddString(String acType) => [];
  List<dynamic> getACTypeRemoveString(String acType) => [];
  String getACTypeName(String acType) => acType;

  // ---------------------------------------------------------------------------
  // Skill multiplier
  // ---------------------------------------------------------------------------

  int getSkillMultiplierForLevel(int level) {
    if (skillMultiplierLevels.isEmpty) return level <= 1 ? 4 : 2;
    // TODO: parse skillMultiplierLevels tokens
    return level <= 1 ? 4 : 2;
  }

  void addSkillMultiplierLevel(String skillMult) {
    skillMultiplierLevels.add(skillMult);
  }

  void removeSkillMultiplierLevels() => skillMultiplierLevels.clear();

  // ---------------------------------------------------------------------------
  // Deity
  // ---------------------------------------------------------------------------

  String getDeityTerm() => _deityTerm;
  void setDeityTerm(String term) { _deityTerm = term; }

  // ---------------------------------------------------------------------------
  // XP
  // ---------------------------------------------------------------------------

  bool isXPEnabled() => _xpEnabled;
  void setXPEnabled(bool enabled) { _xpEnabled = enabled; }

  XPTable? getXPTableNamed(String name) => xpTableInfo[name];
  XPTable? getLevelInfo(String xpTableName) => xpTableInfo[xpTableName];

  void addLevelInfo(String xpTableName, LevelInfo levInfo) {
    xpTableInfo.putIfAbsent(xpTableName, () => XPTable(xpTableName, {}));
    xpTableInfo[xpTableName]!.levelXP[levInfo.level] = levInfo.xpRequired;
  }

  Map<int, int> getXPAwards() => Map.unmodifiable(_xpAwards);
  void addXPaward(int crInteger, int value) { _xpAwards[crInteger] = value; }

  Map<int, String> getCRSteps() => Map.unmodifiable(_crSteps);
  void addCRstep(int index, String crstep) { _crSteps[index] = crstep; }

  String getCRThreshold() => _crThreshold;
  void setCRThreshold(String s) { _crThreshold = s; }

  int? getCRInteger(String cr) {
    for (final entry in _crSteps.entries) {
      if (entry.value == cr) return entry.key;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Weapons
  // ---------------------------------------------------------------------------

  List<Type> getWeaponCategories() => List.unmodifiable(weaponCategories);
  void addWeaponCategory(Type category) { weaponCategories.add(category); }

  Set<Type> getWeaponTypes() => Set.unmodifiable(_weaponTypeAbbrev.keys);
  void addWeaponType(Type type, String abbrev) { _weaponTypeAbbrev[type] = abbrev; }
  String getWeaponTypeAbbrev(Type type) => _weaponTypeAbbrev[type] ?? '';

  String getWeaponReachFormula() => _weaponReachFormula;
  void setWeaponReachFormula(String formula) { _weaponReachFormula = formula; }

  int getShortRangeDistance() => _shortRangeDistance;
  void setShortRangeDistance(int d) { _shortRangeDistance = d; }

  // ---------------------------------------------------------------------------
  // Wield categories
  // ---------------------------------------------------------------------------

  List<dynamic> getWieldCategories() => List.unmodifiable(_wieldCategories);
  void addWieldCategory(dynamic wCat) { _wieldCategories.add(wCat); }

  // ---------------------------------------------------------------------------
  // Point buy
  // ---------------------------------------------------------------------------

  List<PointBuyCost> getPointBuyStatCosts() => List.unmodifiable(_pointBuyStatCosts);
  void addPointBuyStatCost(PointBuyCost pbc) { _pointBuyStatCosts.add(pbc); }

  // ---------------------------------------------------------------------------
  // Class types
  // ---------------------------------------------------------------------------

  ClassType? getClassTypeByName(String aClassKey) {
    for (final ct in _classTypes) {
      if (ct.name == aClassKey) return ct;
    }
    return null;
  }

  void addClassType(ClassType ct) { _classTypes.add(ct); }

  // ---------------------------------------------------------------------------
  // Feat template (for FEAT category defaults per game mode)
  // ---------------------------------------------------------------------------

  dynamic getFeatTemplate() => _featTemplate;
  void setFeatTemplate(dynamic template) { _featTemplate = template; }

  // ---------------------------------------------------------------------------
  // Default datasets
  // ---------------------------------------------------------------------------

  void addDefaultDataSet(String dataSetKey) { defaultDataSetList.add(dataSetKey); }
  void clearDefaultDataSetList() { defaultDataSetList.clear(); }

  // ---------------------------------------------------------------------------
  // Misc setters from miscinfo.lst parsing
  // ---------------------------------------------------------------------------

  void setDamageResistanceText(String s) { _damageResistanceText = s; }
  void setDefaultUnitSet(String s) { _defaultUnitSet = s; }
  void setBonusFeatLevels(String s) { bonusFeatLevels.add(s); }
  void setBonusStatLevels(String s) { bonusStatLevels.add(s); }
  void setRankModFormula(String s) { _rankModFormula = s; }
  String getRankModFormula() => _rankModFormula;

  void addAllowedMode(String modeName) { allowedModes.add(modeName); }
  void addPlusCalculation(Type type, String formula) { plusCalcs[type] = formula; }

  void applyPreferences() {
    // TODO: read from PCGenSettings and update fields
  }

  dynamic getUnitSet() => null; // TODO: return loaded UnitSet object

  // ---------------------------------------------------------------------------
  // Comparable / Object
  // ---------------------------------------------------------------------------

  @override
  int compareTo(Object other) {
    if (other is GameMode) return _name.compareTo(other._name);
    return 1;
  }

  @override
  String toString() => getDisplayName();
}
