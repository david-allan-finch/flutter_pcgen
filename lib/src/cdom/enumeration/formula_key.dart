import '../../base/util/case_insensitive_map.dart';

// Typesafe constant for Formula characteristics of a CDOMObject.
class FormulaKey {
  static final CaseInsensitiveMap<FormulaKey> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  static final FormulaKey levelAdjustment = getConstant('LEVEL_ADJUSTMENT');
  static final FormulaKey startSkillPoints = getConstant('START_SKILL_POINTS');
  static final FormulaKey cost = getConstant('COST');
  static final FormulaKey basecost = getConstant('BASECOST');
  static final FormulaKey pageUsage = getConstant('PAGE_USAGE');
  static final FormulaKey cr = getConstant('CR');
  static final FormulaKey crmod = getConstant('CRMOD');
  static final FormulaKey select = getConstant('SELECT', defaultFormula: '1');
  static final FormulaKey numchoices = getConstant('NUMCHOICES');
  static final FormulaKey size = getConstant('SIZE', defaultFormula: '0');
  static final FormulaKey statMod = getConstant('STAT_MOD');
  static final FormulaKey skillPointsPerLevel = getConstant('SKILL_POINTS_PER_LEVEL');

  final String _fieldName;
  final String _defaultFormula;
  final int ordinal;

  FormulaKey._(this._fieldName, this._defaultFormula) : ordinal = _ordinalCount++;

  String getDefault() => _defaultFormula;

  @override
  String toString() => _fieldName;

  static FormulaKey getConstant(String name, {String defaultFormula = '0'}) {
    final existing = _typeMap[name];
    if (existing != null) return existing;
    final key = FormulaKey._(name, defaultFormula);
    _typeMap[name] = key;
    return key;
  }

  static FormulaKey valueOf(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined FormulaKey');
    return key;
  }

  static Iterable<FormulaKey> getAllConstants() => List.unmodifiable(_typeMap.values());

  static void clearConstants() => _typeMap.clear();
}
