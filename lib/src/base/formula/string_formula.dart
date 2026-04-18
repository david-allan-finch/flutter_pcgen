import 'formula.dart';

// A Formula backed by a String expression.
class StringFormula implements Formula {
  final String _expression;

  const StringFormula(this._expression);

  @override
  num resolve(dynamic pc, String source) {
    // Attempt to parse as number first
    final n = num.tryParse(_expression);
    if (n != null) return n;
    // Non-static: would need full formula evaluation engine
    throw StateError('Cannot resolve non-static formula without PC: $_expression');
  }

  @override
  num resolveStatic() {
    final n = num.tryParse(_expression);
    if (n != null) return n;
    throw StateError('Formula is not static: $_expression');
  }

  @override
  num resolveEquipment(dynamic equipment, bool primary, dynamic pc, String source) {
    return resolve(pc, source);
  }

  @override
  bool isStatic() => num.tryParse(_expression) != null;

  @override
  bool isValid() => _expression.isNotEmpty;

  @override
  String toString() => _expression;
}
