/// Evaluates PCGen LST formula strings.
///
/// Handles arithmetic, comparison operators (returning 0/1), built-in
/// functions (min, max, floor, ceil, abs, if), and named variable resolution
/// via a [FormulaContext].
///
/// Examples of supported formulas:
///   "STR"                         → stat modifier for STR
///   "CL/2+2"                      → class level / 2 + 2
///   "min(CL, 20)"                 → min of class level and 20
///   "floor(TL/3)"                 → floor of total level / 3
///   "1+(TL>=5)"                   → 1 if TL < 5, 2 if TL >= 5
///   "max(CHA, 0)"                 → CHA modifier, floored at 0
///   "STRSCORE-10"                 → raw STR score minus 10
///   "classlevel(\"Fighter\")"     → levels in the Fighter class
///   "0.5*(STR>=0)"                → 0.5 if STR modifier non-negative, else 0

library;

class FormulaContext {
  /// Stat modifiers keyed by abbreviation: 'STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'
  final Map<String, int> statMods;

  /// Raw stat scores: 'STRSCORE', 'DEXSCORE', etc.
  final Map<String, int> statScores;

  /// Total character level.
  final int totalLevel;

  /// Class level by class key/name (lower-cased for lookup).
  final Map<String, int> classLevels;

  /// Named variables defined via DEFINE: tokens (VAR storage).
  final Map<String, double> variables;

  const FormulaContext({
    this.statMods = const {},
    this.statScores = const {},
    this.totalLevel = 0,
    this.classLevels = const {},
    this.variables = const {},
  });

  /// Resolve a variable name to a numeric value.
  /// Returns null if the name is not recognised.
  double? resolve(String name) {
    final upper = name.toUpperCase();

    // Stat modifiers: STR, DEX, CON, INT, WIS, CHA
    if (statMods.containsKey(upper)) return statMods[upper]!.toDouble();

    // Raw scores: STRSCORE, DEXSCORE, ...
    if (upper.endsWith('SCORE')) {
      final abb = upper.substring(0, upper.length - 5);
      if (statScores.containsKey(abb)) return statScores[abb]!.toDouble();
    }

    // Total level aliases
    if (upper == 'TL' || upper == 'CL' || upper == 'HD' || upper == 'ECL') {
      return totalLevel.toDouble();
    }

    // Named variables
    if (variables.containsKey(name)) return variables[name]!;
    if (variables.containsKey(upper)) return variables[upper]!;

    // Unknown — default to 0 (many DEFINE: vars may not be set yet)
    return 0.0;
  }

  /// Class level for a specific class (case-insensitive partial match).
  double classLevel([String? className]) {
    if (className == null || className.isEmpty) return totalLevel.toDouble();
    final lower = className.toLowerCase();
    for (final entry in classLevels.entries) {
      if (entry.key.toLowerCase() == lower ||
          entry.key.toLowerCase().contains(lower)) {
        return entry.value.toDouble();
      }
    }
    return 0.0;
  }
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class FormulaEvaluator {
  /// Evaluate [formula] against the given [context].
  /// Returns 0.0 on any parse/evaluation error.
  static double evaluate(String formula, FormulaContext context) {
    final trimmed = formula.trim();
    if (trimmed.isEmpty) return 0.0;

    // Fast path: pure integer
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt.toDouble();

    // Fast path: pure double
    final asDouble = double.tryParse(trimmed);
    if (asDouble != null) return asDouble;

    try {
      final parser = _Parser(trimmed, context);
      return parser.parseExpr();
    } catch (_) {
      return 0.0;
    }
  }
}

// ---------------------------------------------------------------------------
// Recursive-descent parser
// ---------------------------------------------------------------------------

class _Parser {
  final String _src;
  final FormulaContext _ctx;
  int _pos = 0;

  _Parser(this._src, this._ctx);

  // ---- Entry ---------------------------------------------------------------

  double parseExpr() {
    final v = _parseAdditive();
    _skipWs();
    return v;
  }

  // ---- Additive: expr + expr  |  expr - expr --------------------------------

  double _parseAdditive() {
    var left = _parseMultiplicative();
    while (true) {
      _skipWs();
      if (_cur() == '+') {
        _pos++;
        left += _parseMultiplicative();
      } else if (_cur() == '-' && !_isUnaryMinus()) {
        _pos++;
        left -= _parseMultiplicative();
      } else {
        break;
      }
    }
    return left;
  }

  // ---- Multiplicative: expr * expr  |  expr / expr -------------------------

  double _parseMultiplicative() {
    var left = _parseUnary();
    while (true) {
      _skipWs();
      if (_cur() == '*') {
        _pos++;
        left *= _parseUnary();
      } else if (_cur() == '/') {
        _pos++;
        final right = _parseUnary();
        left = right != 0 ? left / right : 0;
      } else {
        break;
      }
    }
    return left;
  }

  // ---- Unary: -expr --------------------------------------------------------

  double _parseUnary() {
    _skipWs();
    if (_cur() == '-') {
      _pos++;
      return -_parseUnary();
    }
    return _parsePrimary();
  }

  // ---- Primary: number | '(' expr ')' | function | identifier --------------

  double _parsePrimary() {
    _skipWs();
    final c = _cur();

    if (c == '(') {
      _pos++; // consume '('
      final v = parseExpr();
      _skipWs();
      if (_cur() == ')') _pos++;
      return v;
    }

    // Number literal (possibly with leading '-' handled by unary)
    if (_isDigit(c) || c == '.') {
      return _parseNumber();
    }

    // String literal: "ClassName" — used as argument to classlevel() etc.
    // Treat as class level lookup directly.
    if (c == '"' || c == "'") {
      final quote = c;
      _pos++;
      final start = _pos;
      while (_pos < _src.length && _src[_pos] != quote) _pos++;
      final str = _src.substring(start, _pos);
      if (_pos < _src.length) _pos++; // consume closing quote
      // Return class level for the named class
      return _ctx.classLevel(str);
    }

    // Identifier / function call
    if (_isAlpha(c) || c == '_') {
      return _parseIdentifierOrCall();
    }

    return 0.0;
  }

  // ---- Number literal -------------------------------------------------------

  double _parseNumber() {
    final start = _pos;
    while (_pos < _src.length && (_isDigit(_src[_pos]) || _src[_pos] == '.')) {
      _pos++;
    }
    return double.tryParse(_src.substring(start, _pos)) ?? 0.0;
  }

  // ---- Identifier or function call -----------------------------------------

  double _parseIdentifierOrCall() {
    final start = _pos;
    // Allow alphanumeric, underscore, dot (for STAT.MOD etc.)
    while (_pos < _src.length &&
        (_isAlphaNum(_src[_pos]) || _src[_pos] == '_' || _src[_pos] == '.')) {
      _pos++;
    }
    final name = _src.substring(start, _pos);

    _skipWs();

    // Function call?
    if (_cur() == '(') {
      _pos++; // consume '('

      // Special case: classlevel("ClassName") and mastervar("VarName") —
      // we need the raw string argument, not a numeric evaluation.
      final nameLower = name.toLowerCase();
      if (nameLower == 'classlevel' || nameLower == 'mastervar' || nameLower == 'var') {
        _skipWs();
        double result = 0;
        if (_cur() == '"' || _cur() == "'") {
          final quote = _cur();
          _pos++;
          final start = _pos;
          while (_pos < _src.length && _src[_pos] != quote) _pos++;
          final str = _src.substring(start, _pos);
          if (_pos < _src.length) _pos++;
          if (nameLower == 'classlevel') {
            result = _ctx.classLevel(str);
          } else {
            result = _ctx.resolve(str) ?? 0.0;
          }
        } else if (_cur() != ')') {
          result = parseExpr();
        }
        _skipWs();
        if (_cur() == ')') _pos++;
        return result;
      }

      final args = <double>[];
      _skipWs();
      if (_cur() != ')') {
        args.add(parseExpr());
        _skipWs();
        while (_cur() == ',') {
          _pos++;
          args.add(parseExpr());
          _skipWs();
        }
      }
      if (_cur() == ')') _pos++;
      return _callFunction(nameLower, args);
    }

    // Variable resolved from context, possibly followed by comparison
    final value = _resolveVariable(name);

    _skipWs();

    // Comparison operators return 1.0 or 0.0 (used as boolean in formulas)
    if (_pos + 1 < _src.length) {
      final two = _src.substring(_pos, _pos + 2);
      if (two == '>=') { _pos += 2; return (value >= _parseUnary()) ? 1.0 : 0.0; }
      if (two == '<=') { _pos += 2; return (value <= _parseUnary()) ? 1.0 : 0.0; }
      if (two == '!=') { _pos += 2; return (value != _parseUnary()) ? 1.0 : 0.0; }
      if (two == '==') { _pos += 2; return (value == _parseUnary()) ? 1.0 : 0.0; }
    }
    if (_cur() == '>') { _pos++; return (value > _parseUnary()) ? 1.0 : 0.0; }
    if (_cur() == '<') { _pos++; return (value < _parseUnary()) ? 1.0 : 0.0; }

    return value;
  }

  // ---- Built-in functions --------------------------------------------------

  double _callFunction(String name, List<double> args) {
    switch (name) {
      case 'min':
        if (args.length < 2) return args.isEmpty ? 0 : args[0];
        return args.reduce((a, b) => a < b ? a : b);
      case 'max':
        if (args.length < 2) return args.isEmpty ? 0 : args[0];
        return args.reduce((a, b) => a > b ? a : b);
      case 'floor':
        return args.isEmpty ? 0 : args[0].floorToDouble();
      case 'ceil':
        return args.isEmpty ? 0 : args[0].ceilToDouble();
      case 'abs':
        return args.isEmpty ? 0 : args[0].abs();
      case 'if':
        // if(condition, trueVal, falseVal)
        if (args.length < 3) return 0;
        return args[0] != 0 ? args[1] : args[2];
      case 'classlevel':
        // classlevel("ClassName") or classlevel()
        // The class name arg is read as an identifier; we get 0.0 from context.
        // In practice the arg is already a resolved 0.0; we use totalLevel as fallback.
        return _ctx.classLevel();
      case 'var':
        // var("VarName") — look up a named variable
        return args.isEmpty ? 0 : args[0]; // already resolved if name was recognised
      case 'mastervar':
        return args.isEmpty ? 0 : args[0];
      default:
        return 0.0;
    }
  }

  // ---- Variable resolution -------------------------------------------------

  double _resolveVariable(String name) {
    // String literals inside quotes (from classlevel("Fighter") etc.)
    if (name.startsWith('"') && name.endsWith('"')) {
      final inner = name.substring(1, name.length - 1);
      return _ctx.classLevel(inner);
    }

    // Strip any .MOD, .BASE, .NOEQUIP, .NOTEMP suffixes
    var base = name;
    for (final suffix in ['.MOD', '.BASE', '.NOEQUIP', '.NOTEMP', '.INT']) {
      if (base.toUpperCase().endsWith(suffix)) {
        base = base.substring(0, base.length - suffix.length);
        break;
      }
    }

    return _ctx.resolve(base) ?? 0.0;
  }

  // ---- Helpers -------------------------------------------------------------

  String _cur() => _pos < _src.length ? _src[_pos] : '';

  void _skipWs() {
    while (_pos < _src.length && _src[_pos] == ' ') _pos++;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
  bool _isAlphaNum(String c) => _isAlpha(c) || _isDigit(c);

  // Distinguish unary minus from binary minus: unary comes after '(' or operator
  bool _isUnaryMinus() {
    if (_pos == 0) return true;
    final prev = _src[_pos - 1];
    return prev == '(' || prev == '+' || prev == '-' || prev == '*' || prev == '/';
  }
}
