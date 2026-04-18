import '../../cdom/base/concrete_prereq_object.dart';

// Enum for the possible stacking modifiers a bonus can have.
enum StackType {
  /// This bonus will follow the normal stacking rules.
  normal,

  /// This bonus will always stack regardless of its type.
  stack,

  /// This bonus will stack with other bonuses of its own type but not
  /// with bonuses of other types.
  replace,
}

/// Abstract base class for bonus objects.
///
/// Represents a BONUS tag from LST data, e.g. BONUS:STAT|STR|2|TYPE=Enhancement
abstract class BonusObj extends ConcretePrereqObject {
  List<Object> _bonusInfo = [];
  final Map<String, String> _dependMap = {};

  // The formula value of the bonus (stored as a string for simplicity)
  String _bonusFormula = '0';
  bool _formulaIsStatic = true;

  /// The name of the bonus e.g. STAT or COMBAT
  String _bonusName = '';

  /// The type of the bonus e.g. Enhancement or Dodge
  String _bonusType = '';
  String _varPart = '';
  String _typeOfBonus = Bonus.bonusUndefined;
  String? _stringRepresentation;
  String? _tokenSource;
  String? _originalString;

  StackType _stackingFlag = StackType.normal;

  /// Get Bonus Info as a comma-separated uppercase string.
  String getBonusInfo() {
    if (_bonusInfo.isNotEmpty) {
      return _bonusInfo
          .map((info) => unparseToken(info))
          .join(',')
          .toUpperCase();
    }
    return '|ERROR';
  }

  /// Return a list of the unparsed (converted back to strings) bonus info entries.
  List<String> getUnparsedBonusInfoList() {
    return _bonusInfo.map((info) => unparseToken(info)).toList();
  }

  /// Get the raw bonus info list.
  List<Object> getBonusInfoList() => _bonusInfo;

  /// Get Bonus Name
  String getBonusName() => _bonusName;

  /// Get depends on given a key
  bool getDependsOn(String aString) => _dependMap.containsKey(aString);

  /// Get depends on given a list of keys
  bool getDependsOnList(List<String> aList) {
    for (final key in aList) {
      if (_dependMap.containsKey(key)) return true;
    }
    return false;
  }

  /// Check if this bonus requires bonuses of a particular name to be resolved first.
  bool getDependsOnBonusName(String bonusName) {
    return _dependMap.containsKey('NAME|$bonusName');
  }

  /// Report on the dependencies of the bonus.
  String listDependsMap() {
    final buff = StringBuffer('[');
    for (final key in _dependMap.keys) {
      if (buff.length > 1) buff.write(', ');
      buff.write(key);
    }
    buff.write(']');
    return buff.toString();
  }

  /// Get type of Bonus
  String getTypeOfBonus() => _typeOfBonus;

  /// Get the bonus type string
  String getTypeString() => _bonusType;

  /// Set value from a formula string. Returns the formula string.
  String setValue(String bValue) {
    _bonusFormula = bValue;
    // Try to parse as a number - if it succeeds, it's static
    try {
      double.parse(bValue);
      _formulaIsStatic = true;
    } catch (_) {
      _formulaIsStatic = false;
      _buildDependMap(bValue.toUpperCase());
    }
    _stringRepresentation = null;
    return _bonusFormula;
  }

  /// Get the bonus formula string
  String getFormula() => _bonusFormula;

  /// Get the bonus value as string
  String getValue() => _bonusFormula;

  /// Resolve the formula value using a PlayerCharacter (dynamic to avoid circular dependency).
  num resolve(dynamic pc, String source) {
    if (_formulaIsStatic) {
      try {
        return double.parse(_bonusFormula);
      } catch (_) {
        return 0.0;
      }
    }
    // Delegate to PC variable resolution when available
    if (pc != null) {
      try {
        return (pc as dynamic).getVariableValue(_bonusFormula, source) as num;
      } catch (_) {}
    }
    return 0.0;
  }

  /// Is value static
  bool isValueStatic() => _formulaIsStatic;

  /// Set the variable
  void setVariable(String aString) {
    _varPart = aString.toUpperCase();
  }

  /// Get the variable
  String getVariable() => _varPart;

  /// Has bonus type string
  bool hasTypeString() => _bonusType.isNotEmpty;

  /// Has variable
  bool hasVariable() => _varPart.isNotEmpty;

  /// Retrieve the persistent text for this bonus (PCC/LST format).
  String getPCCText() {
    if (_stringRepresentation == null) {
      final sb = StringBuffer();
      sb.write(getTypeOfBonus());
      if (_varPart.isNotEmpty) {
        sb.write(_varPart);
      }
      if (_bonusInfo.isNotEmpty) {
        for (int i = 0; i < _bonusInfo.length; i++) {
          sb.write(i == 0 ? '|' : ',');
          sb.write(unparseToken(_bonusInfo[i]));
        }
      } else {
        sb.write('|ERROR');
      }
      sb.write('|');
      sb.write(_bonusFormula);
      if (_bonusType.isNotEmpty) {
        sb.write('|TYPE=');
        sb.write(_bonusType);
      }
      // Prerequisites would be appended here in a full implementation
      _stringRepresentation = sb.toString();
    }
    return _stringRepresentation!;
  }

  @override
  String toString() => getPCCText();

  void setBonusName(String aName) {
    _bonusName = aName;
  }

  void setTypeOfBonus(String type) {
    _typeOfBonus = type;
    _stringRepresentation = null;
  }

  void addBonusInfo(Object obj) {
    _bonusInfo.add(obj);
    _stringRepresentation = null;
  }

  void replaceBonusInfo(Object oldObj, Object newObj) {
    for (int i = 0; i < _bonusInfo.length; i++) {
      if (identical(_bonusInfo[i], oldObj)) {
        _bonusInfo[i] = newObj;
        _stringRepresentation = null;
        break;
      }
    }
  }

  bool addType(String typeString) {
    if (_bonusType.isEmpty) {
      _bonusType = typeString.toUpperCase();
      _stringRepresentation = null;
      return true;
    }
    return false;
  }

  /// Sets the stacking flag for this bonus.
  void setStackingFlag(StackType aFlag) {
    _stackingFlag = aFlag;
  }

  /// Gets the stacking flag for this bonus.
  StackType getStackingFlag() => _stackingFlag;

  /// Parse a token for the bonus info. Subclasses must implement this.
  bool parseToken(dynamic context, String token);

  /// Unparse a bonus info token back to a string. Subclasses must implement this.
  String unparseToken(Object obj);

  /// Get the bonus type handled by this subclass.
  String getBonusHandled();

  void _buildDependMap(String aString) {
    _addImpliedDependenciesFor(aString);

    // Process nested parentheses
    String working = aString;
    while (working.contains('(')) {
      final x = _innerMostStringStart(working);
      final y = _innerMostStringEnd(working);
      if (y < x) return;
      final bString = working.substring(x + 1, y);
      _buildDependMap(bString);
      working = working.substring(0, x) + working.substring(y + 1);
    }

    if (working.contains('(') || working.contains(')') || working.contains('%')) {
      return;
    }

    // Tokenize on .,
    final tokens = working.split(RegExp(r'[.,]'));
    for (final controlString in tokens) {
      if (controlString == 'IF' ||
          controlString == 'THEN' ||
          controlString == 'ELSE' ||
          controlString == 'GT' ||
          controlString == 'GTEQ' ||
          controlString == 'EQ' ||
          controlString == 'LTEQ' ||
          controlString == 'LT') {
        continue;
      }

      final mathTokens = controlString.split(RegExp(r'[+\-/*>=<"]'));
      for (final mToken in mathTokens) {
        String newString = mToken;
        bool found = false;
        while (!found) {
          String testString;
          if (newString.contains('MAX')) {
            final idx = newString.indexOf('MAX');
            testString = newString.substring(0, idx);
            newString = newString.substring(idx + 3);
          } else if (newString.contains('MIN')) {
            final idx = newString.indexOf('MIN');
            testString = newString.substring(0, idx);
            newString = newString.substring(idx + 3);
          } else {
            testString = newString;
            found = true;
          }
          final numParsed = double.tryParse(testString);
          if (numParsed == null && testString.isNotEmpty) {
            String dep = testString;
            if (dep.startsWith('MOVE[')) {
              dep = 'TYPE.' + dep.substring(5, dep.length - 1);
            }
            _dependMap[dep] = '1';
            _addImpliedDependenciesFor(dep);
          }
        }
      }
    }
  }

  void _addImpliedDependenciesFor(String aString) {
    if (aString.contains('SKILLINFO(')) {
      _dependMap['JEPFORMULA'] = '1';
    }
    if (aString.contains('HP')) {
      _dependMap['CURRENTMAX'] = '1';
    }
    if (aString.contains('SKILL.') || aString.contains('SKILLINFO')) {
      _dependMap['NAME|STAT'] = '1';
    }
    if (aString.contains('MODEQUIPMAXDEX')) {
      _dependMap['MAXDEX'] = '1';
    }
    if (aString == 'BAB') {
      _dependMap['BASEAB'] = '1';
    }
  }

  int _innerMostStringStart(String s) {
    int last = -1;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') last = i;
    }
    return last;
  }

  int _innerMostStringEnd(String s) {
    final start = _innerMostStringStart(s);
    if (start < 0) return -1;
    return s.indexOf(')', start);
  }

  void setTokenSource(String tokenName) {
    _tokenSource = tokenName;
  }

  String? getTokenSource() => _tokenSource;

  void putOriginalString(String bonusString) {
    _originalString = bonusString;
  }

  String? getLSTformat() => _originalString;

  String getDescription() => '${getTypeOfBonus()} ${getBonusInfo()}';

  /// Identify if this bonus cannot have its target changed to upper case.
  bool requiresRealCaseTarget() => false;

  BonusObj cloneBonus() {
    throw UnimplementedError('BonusObj.cloneBonus() must be implemented by subclass');
  }

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! BonusObj) return false;
    return _bonusFormula == obj._bonusFormula &&
        _bonusName == obj._bonusName &&
        _bonusType == obj._bonusType &&
        _stackingFlag == obj._stackingFlag &&
        _listEquals(_bonusInfo, obj._bonusInfo);
  }

  bool _listEquals(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      _bonusFormula.hashCode ^
      _bonusName.hashCode ^
      _bonusType.hashCode ^
      _stackingFlag.hashCode;
}

/// Utility class for creating BonusObj instances from LST strings.
class Bonus {
  static const String bonusUndefined = '*UNDEFINED';

  Bonus._(); // Prevent instantiation

  /// Create a new BonusObj from a bonus string.
  /// Returns null if parsing fails.
  /// Note: Full implementation requires TokenLibrary and LoadContext.
  static BonusObj? newBonus(dynamic context, String bonusString) {
    // Simplified stub - full implementation would require
    // TokenLibrary.getBonus() and proper parsing infrastructure
    // This is a placeholder that can be filled in when the persistence layer is translated.
    return null;
  }
}
