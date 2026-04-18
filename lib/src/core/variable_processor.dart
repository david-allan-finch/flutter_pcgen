// VariableProcessor.dart
// Translated from pcgen/core/VariableProcessor.java
// JEP (PJEP/PjepPool) and ExportHandler are stubbed.

import 'player_character.dart';
import 'character/cached_variable.dart';
import 'character/character_spell.dart';

/// Enum representing the four basic math operations used by the broken parser.
enum _MathOp { plus, minus, multiply, divide }

/// Base class for PCGen variable processors.
/// Converts a formula or variable name into a numeric value.
abstract class VariableProcessor {
  String _jepIndent = '';
  final PlayerCharacter pc;

  int _cachePaused = 0;
  int _serial = 0;

  final Map<String, CachedVariable<String>> _sVariableCache = {};
  final Map<String, CachedVariable<double>> _fVariableCache = {};

  VariableProcessor(this.pc);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Evaluate a variable for this character.
  double? getVariableValue(
      CharacterSpell? aSpell, String varString, String src, int spellLevelTemp) {
    double? result = getJepOnlyVariableValue(aSpell, varString, src, spellLevelTemp);

    if (result == null) {
      result = _processBrokenParser(aSpell, varString, src, spellLevelTemp);
      final String cacheString = _makeCacheString(aSpell, varString, src, spellLevelTemp);
      addCachedVariable(cacheString, result);
    }

    return result;
  }

  /// Attempt to evaluate using the JEP parser. Returns null if not a JEP formula.
  double? getJepOnlyVariableValue(
      CharacterSpell? aSpell, String varString, String src, int spellLevelTemp) {
    // Try to parse as a plain number first.
    final double? direct = double.tryParse(varString);
    if (direct != null) return direct;

    final String cacheString = _makeCacheString(aSpell, varString, src, spellLevelTemp);
    final double? total = getCachedVariable(cacheString);
    if (total != null) return total;

    // stub: JEP formula evaluation (PJEP/PjepPool) – not translated
    // Returning null causes fallback to broken parser.
    return null;
  }

  String _makeCacheString(
      CharacterSpell? aSpell, String varString, String src, int spellLevelTemp) {
    final StringBuffer cS = StringBuffer()
      ..write(varString)
      ..write('#')
      ..write(src);

    if (aSpell != null) {
      if (aSpell.getSpell() != null) {
        cS.write(aSpell.getSpell()!.getKeyName());
      }
      cS.write(aSpell.getFixedCasterLevel());
    }

    if (spellLevelTemp > 0) {
      cS.write(spellLevelTemp);
    }

    return cS.toString();
  }

  // ---------------------------------------------------------------------------
  // Abstract method – subclasses supply internal variable lookup
  // ---------------------------------------------------------------------------

  double? getInternalVariable(CharacterSpell? aSpell, String valString, String src);

  // ---------------------------------------------------------------------------
  // Variable lookup
  // ---------------------------------------------------------------------------

  double? lookupVariable(String term, String src, CharacterSpell? spell) {
    double? retVal;

    if (pc.hasVariable(term)) {
      final double? value = pc.getVariable(term, true);
      // log: variable for: '$term' = $value
      retVal = value;
    }

    if (retVal == null) {
      retVal = getInternalVariable(spell, term, src);
    }

    if (retVal == null) {
      final String? evReturn = getExportVariable(term);
      if (evReturn != null) {
        retVal = _convertToFloat(term, evReturn);
      }
    }

    return retVal;
  }

  double? _convertToFloat(String element, String foo) {
    final double? d = double.tryParse(foo);
    if (d != null && !d.isNaN) {
      // log: export variable for: '$element' = $d
      return d;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------------

  double? getCachedVariable(String lookup) {
    if (isCachePaused()) return null;
    final CachedVariable<double>? cached = _fVariableCache[lookup];
    if (cached != null) {
      if (cached.getSerial() >= getSerial()) {
        return cached.getValue();
      }
      _fVariableCache.remove(lookup);
    }
    return null;
  }

  void addCachedVariable(String lookup, double? value) {
    if (isCachePaused()) return;
    final CachedVariable<double> cached = CachedVariable<double>();
    cached.setSerial(getSerial());
    cached.setValue(value);
    _fVariableCache[lookup] = cached;
  }

  void restartCache() {
    _serial = _cachePaused;
    _cachePaused = 0;
  }

  void pauseCache() {
    _cachePaused = _serial;
  }

  bool isCachePaused() => _cachePaused > 0;

  int getSerial() => _serial;

  void setSerial(int serial) {
    _serial = serial;
  }

  String? getCachedString(String lookup) {
    if (isCachePaused()) return null;
    final CachedVariable<String>? cached = _sVariableCache[lookup];
    if (cached != null) {
      if (cached.getSerial() >= getSerial()) {
        return cached.getValue();
      }
      _sVariableCache.remove(lookup);
    }
    return null;
  }

  void addCachedString(String lookup, String value) {
    if (isCachePaused()) return;
    final CachedVariable<String> cached = CachedVariable<String>();
    cached.setSerial(getSerial());
    cached.setValue(value);
    _sVariableCache[lookup] = cached;
  }

  /// stub: ExportHandler token replacement – returns empty string
  String getExportVariable(String valString) {
    // stub: ExportHandler.createExportHandler + replaceTokenSkipMath
    return '';
  }

  PlayerCharacter getPc() => pc;

  // ---------------------------------------------------------------------------
  // Broken (non-JEP) parser
  // ---------------------------------------------------------------------------

  double _processBrokenParser(
      CharacterSpell? aSpell, String aString, String src, int spellLevelTemp) {
    double total = 0.0;
    aString = aString.toUpperCase();
    src = src.toUpperCase();

    // Evaluate inner-most parentheses first
    while (aString.lastIndexOf('(') >= 0) {
      final int x = _innerMostStringStart(aString);
      final int y = _innerMostStringEnd(aString);
      if (y < x) {
        // log: Missing closing parenthesis: $aString
        return total;
      }
      final String bString = aString.substring(x + 1, y);
      final double? val = getVariableValue(aSpell, bString, src, spellLevelTemp);
      aString = aString.substring(0, x) + (val ?? 0.0).toString() + aString.substring(y + 1);
    }

    const String delimiter = '+-/*';
    String valString = '';
    _MathOp mode = _MathOp.plus;
    _MathOp nextMode = _MathOp.plus;

    if (aString.startsWith('.IF.')) {
      // .IF. conditional processing
      final String rest = aString.substring(4);
      final List<String> tokens = rest.split('.');

      StringBuffer bString = StringBuffer();
      double? val1;
      double? val2;
      double? valt;
      int comp = 0;

      for (int ti = 0; ti < tokens.length; ti++) {
        final String cString = tokens[ti];
        if (['GT', 'GTEQ', 'EQ', 'LTEQ', 'LT'].contains(cString)) {
          final String bs = bString.toString();
          val1 = getVariableValue(aSpell,
              bs.endsWith('.') ? bs.substring(0, bs.length - 1) : bs, src, spellLevelTemp);
          bString = StringBuffer();
          // skip next '.' separator (already split)
          switch (cString) {
            case 'LT':
              comp = 1;
              break;
            case 'LTEQ':
              comp = 2;
              break;
            case 'EQ':
              comp = 3;
              break;
            case 'GT':
              comp = 4;
              break;
            case 'GTEQ':
              comp = 5;
              break;
          }
        } else if (cString == 'THEN') {
          final String bs = bString.toString();
          val2 = getVariableValue(aSpell,
              bs.endsWith('.') ? bs.substring(0, bs.length - 1) : bs, src, spellLevelTemp);
          bString = StringBuffer();
        } else if (cString == 'ELSE') {
          final String bs = bString.toString();
          valt = getVariableValue(aSpell,
              bs.endsWith('.') ? bs.substring(0, bs.length - 1) : bs, src, spellLevelTemp);
          bString = StringBuffer();
        } else {
          bString.write(cString);
          if (ti < tokens.length - 1) bString.write('.');
        }
      }

      if (val1 != null && val2 != null && valt != null) {
        final double valf =
            getVariableValue(aSpell, bString.toString(), src, spellLevelTemp) ?? 0.0;
        total = valt;
        switch (comp) {
          case 1: // LT
            if (val1 >= val2) total = valf;
            break;
          case 2: // LTEQ
            if (val1 > val2) total = valf;
            break;
          case 3: // EQ
            if ((val1 - val2).abs() > 1e-9) total = valf;
            break;
          case 4: // GT
            if (val1 <= val2) total = valf;
            break;
          case 5: // GTEQ
            if (val1 < val2) total = valf;
            break;
          default:
            // log: ERROR - badly formed statement: $aString:$val1:$val2:$comp
            return 0.0;
        }
        return total;
      }
    }

    // Main arithmetic loop
    for (int i = 0; i < aString.length; ++i) {
      valString += aString[i];

      if (i == aString.length - 1 ||
          delimiter.indexOf(aString[i]) >= 0) {
        if (valString.length == 1 && delimiter.indexOf(aString[i]) >= 0) {
          continue;
        }
        if (delimiter.indexOf(aString[i]) >= 0) {
          valString = valString.substring(0, valString.length - 1);
        }

        final double? tmp = lookupVariable(valString, src, aSpell);
        if (tmp != null) {
          valString = tmp.toString();
        }

        switch (aString[i]) {
          case '+':
            nextMode = _MathOp.plus;
            break;
          case '-':
            nextMode = _MathOp.minus;
            break;
          case '*':
            nextMode = _MathOp.multiply;
            break;
          case '/':
            nextMode = _MathOp.divide;
            break;
        }

        if (valString.isNotEmpty) {
          double valFloat = 0.0;
          try {
            valFloat = double.parse(valString);
          } catch (_) {
            // ignore, use 0
          }
          switch (mode) {
            case _MathOp.plus:
              total += valFloat;
              break;
            case _MathOp.minus:
              total -= valFloat;
              break;
            case _MathOp.multiply:
              total *= valFloat;
              break;
            case _MathOp.divide:
              total /= valFloat;
              break;
          }
        }

        mode = nextMode;
        nextMode = _MathOp.plus;
        valString = '';
      }
    }

    return total;
  }

  /// Finds the index of the opening parenthesis of the innermost group.
  static int _innerMostStringStart(String s) {
    int last = -1;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '(') last = i;
    }
    return last;
  }

  /// Finds the index of the closing parenthesis that matches the innermost open.
  static int _innerMostStringEnd(String s) {
    final int start = _innerMostStringStart(s);
    if (start < 0) return -1;
    for (int i = start + 1; i < s.length; i++) {
      if (s[i] == ')') return i;
    }
    return -1;
  }
}
