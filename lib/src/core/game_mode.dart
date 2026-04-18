import '../cdom/base/constants.dart';
import '../cdom/enumeration/type.dart';

// XP table entry
class XPTable {
  final String name;
  final Map<int, int> levelXP;

  const XPTable(this.name, this.levelXP);

  int getXPForLevel(int level) => levelXP[level] ?? 0;
}

// Handles game mode configuration (D&D 3.5, Pathfinder, 5e, etc).
final class GameMode implements Comparable<Object> {
  String _name = '';
  String _displayName = '';
  List<String> allowedModes = [];
  List<String> bonusFeatLevels = [];
  List<String> bonusStackList = [];
  List<String> bonusStatLevels = [];
  List<String> defaultDataSetList = [];
  Map<String, XPTable> xpTableInfo = {};
  List<String> skillMultiplierLevels = [];
  Map<Type, String> plusCalcs = {};
  Map<String, String> spellRangeMap = {};
  Map<String, String> weaponCategories = {};

  String _althpAbbrev = '';
  String _althpName = '';
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
  String _classType = '';
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
  String _babMaxAtt = '';
  String _babMinVal = '0';
  String _babAttCyc = '5';
  String _rollFormula = '';
  String _moveFormula = '';
  bool _xpEnabled = true;
  String _deityTerm = 'Deity';
  List<String> _gameModeDisplayNames = [];

  // Wield categories
  final List<dynamic> _wieldCategories = [];

  String getName() => _name;
  void setName(String name) { _name = name; }

  String getDisplayName() => _displayName.isEmpty ? _name : _displayName;
  void setDisplayName(String name) { _displayName = name; }

  String getCurrencyUnit() => _currencyUnit;
  void setCurrencyUnit(String unit) { _currencyUnit = unit; }

  String getCurrencyUnitAbbrev() => _currencyUnitAbbrev;
  void setCurrencyUnitAbbrev(String abbrev) { _currencyUnitAbbrev = abbrev; }

  String getDefaultSpellbook() => _defaultSpellbook;
  void setDefaultSpellbook(String book) { _defaultSpellbook = book; }

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

  int getStatMax() => _statMax;
  void setStatMax(int max) { _statMax = max; }

  int getStatMin() => _statMin;
  void setStatMin(int min) { _statMin = min; }

  String getACFormula() => _acformula;
  void setACFormula(String formula) { _acformula = formula; }

  String getBabMaxAtt() => _babMaxAtt;
  void setBabMaxAtt(String maxAtt) { _babMaxAtt = maxAtt; }

  String getBabMinVal() => _babMinVal;
  void setBabMinVal(String minVal) { _babMinVal = minVal; }

  String getBabAttCyc() => _babAttCyc;
  void setBabAttCyc(String attCyc) { _babAttCyc = attCyc; }

  String getSpellBaseDC() => _spellBaseDC;
  void setSpellBaseDC(String formula) { _spellBaseDC = formula; }

  String getDeityTerm() => _deityTerm;
  void setDeityTerm(String term) { _deityTerm = term; }

  bool isXPEnabled() => _xpEnabled;
  void setXPEnabled(bool enabled) { _xpEnabled = enabled; }

  XPTable? getXPTableNamed(String name) => xpTableInfo[name];

  void addXPTable(XPTable table) {
    xpTableInfo[table.name] = table;
  }

  int getSkillMultiplierForLevel(int level) {
    if (skillMultiplierLevels.isEmpty) return 4;
    if (level <= 1) return 4;
    return 2;
  }

  @override
  int compareTo(Object other) {
    if (other is GameMode) {
      return _name.compareTo(other._name);
    }
    return 1;
  }

  @override
  String toString() => getDisplayName();
}
